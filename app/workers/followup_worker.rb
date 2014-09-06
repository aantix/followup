require 'cgi'
require 'thread/pool'

class FollowupWorker
  include Sidekiq::Worker

  LOOKBACK        = 1
  MAX_CONNECTIONS = 10

  def perform(user_id)
    puts "Start! #{Time.now}"

    FollowupInboxWorker.connections||= {}
    FollowupInboxWorker.connections.delete(user_id)

    user = User.find(user_id)
    user.refresh_token!

    FollowupInboxWorker.connections[user.id] = []

    MAX_CONNECTIONS.times do |connection_count|
      print "O"
      FollowupInboxWorker.connections[user.id] << Gmail.new(:xoauth2, user.email, oauth2_token: user.omniauth_token)
      FollowupInboxWorker.perform_async(user.id, LOOKBACK, connection_count + 1)
    end

    puts "Complete! #{Time.now}"
  end

end
