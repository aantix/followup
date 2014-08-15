class Followup
  LOOKBACK = 1

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
      if Email.filtered?(e, @user.email)
        print "x"
      else
        body, signature = Email.extract_body_signature(e.body.to_s)

        if body.nil?
          print "x"
          next
        else
          print "."
        end

        questions       = Question.new(body).questions_from_text

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

end
