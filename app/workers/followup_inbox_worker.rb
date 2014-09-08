class FollowupInboxWorker
  include Sidekiq::Worker

  cattr_accessor :connections

  def perform(user_id, lookback, offset)
    e_count = 1
    options = {after: lookback.days.ago}

    FollowupEmailWorker.emails||={}

    connection = FollowupInboxWorker.connections[user_id][offset - 1]

    inbox      = connection.inbox.emails(options)
    sent       = connection.mailbox(:sent).emails(options)

    {sent => false, inbox => true}.each do |(box, direct_addressment)|
      box.each do |e|
        if e_count % offset == 0
          e_id  = email_id(e, user_id)

          FollowupEmailWorker.emails[e_id] = e
          FollowupEmailWorker.perform_async(e_id, user_id, direct_addressment)
          #FollowupEmailWorker.new.perform(e_id, user_id, direct_addressment)
        end

        e_count+=1
      end
    end

  end

  def email_id(e, user_id)
    "#{e.to_s}-#{user_id}"
  end

end