require 'cgi'
require 'thread/pool'

class FollowupWorker
  include Sidekiq::Worker

  MAX_THREADS = 10
  LOOKBACK    = 1
  @@jobs      = []

  def self.analyze_emails(user)
    puts "Start! #{Time.now}"

    gmails = {}
    pool   = Thread.pool(MAX_THREADS)

    # https://github.com/nu7hatch/gmail/pull/80
    user.refresh_token!

    LOOKBACK.times do |lookback|
      options = {after: (lookback + 1).days.ago, before: lookback.days.ago}

      pool.process do
        puts "here1"
        gmails[lookback]||=Gmail.connect(:xoauth2, user.email, oauth2_token: user.omniauth_token)

        gmail   = gmails[lookback]
        inbox   = gmail.inbox.emails(options)
        sent    = gmail.mailbox(:sent).emails(options)

        {sent => false, inbox => true}.each do |(box, direct_addressment)|
          box.each do |e|
            @@jobs << FollowupWorker.perform_async(e.message, e.thread_id, e.msg_id, e.subject, user.id, direct_addressment)
          end
        end
      end
    end

    puts "Complete! #{Time.now}"
  end

  def perform(msg, thread_id, msg_id, subject, user_id, direct_addressment)
    mail = Mail.read_from_string msg
    user = User.find(user_id)

    @@jobs << EmailProfileImageWorker.perform_async(from(mail), nil, EmailProfileImageWorker::EMAIL_LOOKUP)
    content_type, body = email_body(mail)

    print "."

    unless Email.filtered?(mail, msg, filter_body(mail), user.email, direct_addressment)
      body, signature = Email.extract_body_signature(content_type, body)
      return if body.blank?
      return if from_same_address?(mail)

      thread = user.email_threads.find_or_create_by(thread_id: thread_id)

      email = thread.emails.find_or_create_by(message_id: msg_id) do |eml|
        eml.from_email = from(mail)
        eml.from_name = mail[:from].addrs.first.display_name
        eml.subject = subject
        eml.body = body
        eml.content_type = content_type
        eml.received_on = mail.date
      end

      questions = Question.questions_from_text(body)
      email.questions.delete_all
      questions.each do |question|
        email.questions.find_or_create_by(question: question)
      end
    end

  end

  def from(mail)
    mail[:from].addrs.first.address
  end

  # Prefer the text version vs HTML version for multipart/alternative messages
  def email_body(mail)
    content_type = Email::TEXT

    body = if mail.multipart? # Probably a multipart/alternative message
             p = mail.text_part

             if p.nil?
               p = mail.html_part
               content_type = Email::HTML
             end

             p.present? ? p.decoded : nil
           else
             content_type = Email::HTML if Email.html?(mail.content_type)
             mail.body.decoded
           end

    return nil, nil if body.nil?
    return content_type, body
  end

  def from_same_address?(mail)
    from = mail[:from].addrs.first.address
    tos  = mail[:to].addrs.collect(&:address)

    tos.include?(from)
  rescue
    nil
  end

  # Prefer the html version vs the text version for filtering out emails
  #  usually because the html version will include an unsubscribe link
  def filter_body(mail)
    body = if mail.multipart? # Probably a multipart/alternative message
             p = mail.html_part
             p = mail.text_part if p.nil?

             p.present? ? p.decoded : nil
           else
             mail.body.decoded
           end

    body
  end

end
