require "#{ENV['RAILS_ROOT']}/config/environment.rb"

users = User.all

users.each do |user|
  zone    = ActiveSupport::TimeZone.new(user.time_zone)
  time_at = user.email_send.in_time_zone(zone)

  FollowupWorker.perform_at(time_at, user.id)
end