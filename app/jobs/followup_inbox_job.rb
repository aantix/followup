class FollowupInboxJob < ActiveJob::Base
  DISPLAY_LOOKBACK = 3

  def perform(user_id, send_email = false)
    user  = User.find(user_id)
    user.refresh_token!

    options    = {after: DISPLAY_LOOKBACK.days.ago}
    connection = Gmail.new(:xoauth2, user.email, oauth2_token: user.omniauth_token)
    inbox      = connection.inbox.emails(options)
    sent       = connection.mailbox(:sent).emails(options)

    {sent => false, inbox => true}.each do |(box, direct_addressment)|
      box.each do |e|
        print "." if Rails.env.development?

        thread_id = e.thread_id
        msg_id    = e.msg_id
        subject   = e.subject
        msg       = e.message.raw_source

        puts e.message.raw_source

        #FollowupEmailJob.perform_later(user_id, thread_id, msg_id, subject, msg, direct_addressment)
      end
    end

    # FollowupMailer.daily(User.find(user_id)).deliver_later if send_email
  end

end