require 'cgi'

class Followup
  LOOKBACK = 3

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
    email = {}
    inbox = @gmail.inbox.emails(after: LOOKBACK.days.ago)
    sent  = @gmail.mailbox(:sent).emails(after: LOOKBACK.days.ago)

    all_email = inbox.concat(sent)

    all_email.each do |e|
      mail = Mail.read_from_string e.msg

      content_type, body = email_body(mail)

      if Email.filtered?(e, filter_body(mail), @user.email)
        print "x"
      else
        File.open("/tmp/emails/email#{e.msg_id}.txt", 'w') { |file| file.write body} rescue nil

        body, signature = Email.extract_body_signature(content_type, body)
        binding.pry

        if body.nil?
          print "x"
          next
        else
          print "."
        end

        questions = Question.new(body).questions_from_text

        email[e.thread_id]||=[]
        email[e.thread_id] << [e.subject, Email.from_addresses(e), questions]
      end
    end

    email.each do |thread_id, data|
      last_email = data.last

      puts "#{last_email[0]} (#{last_email[1].first})"
      puts "  https://mail.google.com/mail/u/0/#inbox/#{thread_id}"

      puts last_email[2].join(" ... ")
    end;1

    email
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
