class FollowupInboxJob < ActiveJob::Base
  cattr_accessor :connections

  def perform(user_id, lookback, starting, offset, send_email = false)
    e_count = 1
    options = {after: lookback.days.ago}

    FollowupEmailJob.emails||={}

    connection = FollowupInboxJob.connections[user_id][starting - 1]

    inbox      = connection.inbox.emails(options)
    sent       = connection.mailbox(:sent).emails(options)

    {sent => false, inbox => true}.each do |(box, direct_addressment)|
      box.each do |e|
        print "." if Rails.env.development?

        if e_count == starting
          e_id = email_id(e, user_id)

          FollowupEmailJob.emails[e_id] = e
          FollowupEmailJob.perform_later(e_id, user_id, direct_addressment)
          starting+=offset
        end

        e_count+=1
      end
    end

    FollowupMailer.daily(User.find(user_id)).deliver_later if send_email
  end

  def email_id(e, user_id)
    "#{e.to_s}-#{user_id}"
  end

end