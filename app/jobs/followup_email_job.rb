class FollowupEmailJob < ActiveJob::Base
  cattr_accessor :emails

  def perform(e_id, user_id, direct_addressment)
    e         = FollowupEmailJob.emails[e_id] rescue nil
    return unless e.present?

    thread_id = e.thread_id
    msg_id    = e.msg_id
    subject   = e.subject
    msg       = e.message

    mail      = Mail.read_from_string msg
    user      = User.find(user_id)

    content_type, body = email_body(mail)

    print "." if Rails.env.development?

    unless Email.filtered?(mail, msg, filter_body(mail), user.email, direct_addressment)
      body, signature = Email.extract_body_signature(content_type, body)
      return if body.blank?
      return if from_same_address?(mail)

      from_email = from(mail)
      FollowupProfileInfoJob.perform_later(from_email)

      thread = user.email_threads.with_deleted.find_or_create_by(thread_id: thread_id)

      return if thread.destroyed?

      email  = thread.emails.find_or_create_by(message_id: msg_id) do |eml|
        eml.from_email   = from_email
        eml.from_name    = mail[:from].addrs.first.display_name
        eml.subject      = subject
        eml.body         = body
        eml.content_type = content_type
        eml.received_on  = mail.date
      end

      questions = Question.questions_from_text(body)
      email.questions.delete_all
      questions.each do |question|
        email.questions.find_or_create_by(question: question)
      end
    end

    FollowupEmailJob.emails.delete(e_id)

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