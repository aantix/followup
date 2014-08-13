class Followup
  LOOKBACK = 2

  def initialize(user)
    # https://github.com/nu7hatch/gmail/pull/80
    @user  = user
    @gmail = Gmail.connect(:xoauth2, user.email, oauth2_token: user.omniauth_token)
  end

  # Not only look at retrieving the emails, but extracting all of the emails for a
  #  given thread.  That's the only way to know if someone has replied to someone else,
  #  right?
  #
  # https://github.com/dcparker/ruby-gmail/issues/11
  # http://blog.wojt.eu/post/13496746332/retrieving-gmail-thread-ids-with-ruby
  def emails
    @user.refresh_token!

    email = Hash.new([])
    inbox = @gmail.inbox.emails(after: LOOKBACK.days.ago)
    sent  = @gmail.mailbox(:sent).emails(after: LOOKBACK.days.ago)

    all_email = inbox.concat(sent)

    all_email.each_with_index do |e, i|
      unless Email.filtered?(e, user.email)
        body, signature = Email.extract_body_signature(e.body)
        questions = Email.questions(body)

        email[e.thread_id] << [e.subject, questions]
      end
    end

    email
  end

end
