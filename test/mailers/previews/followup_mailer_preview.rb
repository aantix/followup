class FollowupMailerPreview < ActionMailer::Preview
  def daily
    FollowupMailer.daily(User.first)
  end
end