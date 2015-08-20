class FollowupInboxJob < ActiveJob::Base
  DISPLAY_LOOKBACK = 3

  def perform(user_id, send_email = false)
    user  = User.find(user_id)
    user.refresh_token!
  end

end