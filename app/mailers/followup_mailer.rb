class FollowupMailer < ActionMailer::Base
  default from: "jim.jones1@gmail.com"

  def daily(user)
    @user = user
    @email_threads = @user.current_email_threads
    mail(to: @user.email, subject: "You have #{@email_threads.size} emails that you to follow up on")
  end
end
