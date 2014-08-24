require 'cgi'

class FollowupWorker
  include Sidekiq::Worker

  LOOKBACK = 2

  def perform(user)

    # https://github.com/nu7hatch/gmail/pull/80
    user.refresh_token!

    gmail = Gmail.connect(:xoauth2, user.email, oauth2_token: user.omniauth_token)

    inbox = gmail.inbox.emails(after: LOOKBACK.days.ago)
    sent = gmail.mailbox(:sent).emails(after: LOOKBACK.days.ago)

    #{sent => false, inbox => true}.each do |(box, direct_addressment)|
    {sent => false}.each do |(box, direct_addressment)|
      box.each do |e|

        mail = Mail.read_from_string e.msg

        content_type, body = email_body(mail)

        print "."

        unless Email.filtered?(e, filter_body(mail), user.email, direct_addressment)
          body, signature = Email.extract_body_signature(content_type, body)
          next if body.blank?

          thread = user.email_threads.find_or_create_by(thread_id: e.thread_id)
          from = mail[:from].addrs.first.address

          email = thread.emails.find_or_create_by(message_id: e.msg_id) do |eml|
            eml.from_email = from
            eml.from_name = mail[:from].addrs.first.display_name
            eml.subject = e.subject
            eml.body = body
            eml.content_type = content_type
            eml.received_on = mail.date
          end

          questions = Question.questions_from_text(body)
          questions.each do |question|
            email.questions.create!(question: question)
          end

          EmailProfileImage.download_images_for(from)
        end
      end
    end
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
