class Followup

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
    email     = Hash.new({})

    user.refresh_token
    all_email = @gmail.inbox.emails(:unread, :after => 5.days.ago)

    all_email.each do |e|
      data = gmail.imap.fetch(e.uid, "(X-GM-THRID)")
      thread_id =  data[0].attr["X-GM-THRID"].to_s(16)

      email[thread_id] << e
    end

    email
  end

end
