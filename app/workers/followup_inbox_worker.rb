class FollowupInboxWorker
  include Sidekiq::Worker

  cattr_accessor :connections

  def perform(user_id, lookback, starting, offset)
    e_count = 1
    options = {after: lookback.days.ago}

    FollowupEmailWorker.emails||={}

    connection = FollowupInboxWorker.connections[user_id][starting - 1]

    inbox      = connection.inbox.emails(options)
    sent       = connection.mailbox(:sent).emails(options)

    {sent => false, inbox => true}.each do |(box, direct_addressment)|
      box.each do |e|
        print "."

        if e_count == starting
          e_id = email_id(e, user_id)

          FollowupEmailWorker.emails[e_id] = e
          FollowupEmailWorker.perform_async(e_id, user_id, direct_addressment)
          starting+=offset
        end

        e_count+=1
      end
    end

  end

  def email_id(e, user_id)
    "#{e.to_s}-#{user_id}"
  end

end