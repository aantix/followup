require 'cgi'

class Followup
  LOOKBACK = 6

  def initialize(user)
    # https://github.com/nu7hatch/gmail/pull/80
    @user  = user
    @user.refresh_token!

    @gmail = Gmail.connect(:xoauth2, @user.email, oauth2_token: @user.omniauth_token)
  end

  # Not only look at retrieving the emails, but extracting all of the emails for a
  #  given thread.  That's the only way to know if someone has replied to someone else,
  #  right?
  #
  # https://github.com/dcparker/ruby-gmail/issues/11
  # http://blog.wojt.eu/post/13496746332/retrieving-gmail-thread-ids-with-ruby
  def emails
    inbox = @gmail.inbox.emails(after: LOOKBACK.days.ago)
    sent  = @gmail.mailbox(:sent).emails(after: LOOKBACK.days.ago)

    all_email = inbox.concat(sent)

    all_email.each do |e|
      mail = Mail.read_from_string e.msg

      content_type, body = email_body(mail)

      print "."

      unless Email.filtered?(e, filter_body(mail), @user.email)
        body, signature = Email.extract_body_signature(content_type, body)
        next if body.nil?

        questions = Question.questions_from_text(body)

        thread    = @user.email_threads.find_or_create_by(thread_id: e.thread_id)

        email     = thread.emails.create!(message_id: e.msg_id,
                                          from_email: mail[:from].addrs.first.address,
                                          from_name: mail[:from].addrs.first.display_name,
                                          subject: e.subject,
                                          body: body,
                                          received_on: mail.date)

        questions.each do |question|
          email.questions.create!(question: question)
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
