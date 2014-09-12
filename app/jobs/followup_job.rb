class FollowupJob < ActiveJob::Base
  LOOKBACK         = 1
  DISPLAY_LOOKBACK = 3
  MAX_CONNECTIONS  = 10

  def perform(user_id, email_results)
    FollowupInboxJob.connections||= {}
    FollowupInboxJob.connections.delete(user_id)

    user  = User.find(user_id)
    user.refresh_token!

    FollowupInboxJob.connections[user.id] = []

    MAX_CONNECTIONS.times do |connection_count|
      last_job = (connection_count == MAX_CONNECTIONS - 1) ? true : false

      FollowupInboxJob.connections[user.id] << Gmail.new(:xoauth2, user.email, oauth2_token: user.omniauth_token)
      FollowupInboxJob.perform_later(user.id, LOOKBACK, connection_count + 1, MAX_CONNECTIONS, email_results && last_job)
    end

  end

end
