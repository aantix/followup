ENV["RAILS_ENV"] ||= "production"

# Must schedule this script to start at or after midnight.
#  It takes the current day plus the time the user has specified
#  and schedules the email updates for that timestamp.
#  E.g. perform_at "2014-09-09 09:00:00 -0700"

root   = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require File.join(root, "config", "environment")

logger = Logger.new(File.open("#{root}/log/schedule_reminders_#{Rails.env}.log", 'w+'))
#users  = User.all
users  = User.where(email: "jim.jones1@gmail.com")

users.each do |user|
  zone    = ActiveSupport::TimeZone.new(user.time_zone)
  time_at = Time.parse("#{Date.today} #{user.email_send.strftime("%I:%M %P")}").in_time_zone(zone)

  logger.info "Scheduling #{user.id} to update at #{time_at}"
  # FollowupInboxJob.set(wait_until: time_at).perform_later(user.id, true)
  FollowupInboxJob.perform_at(time_at, user.id)
end