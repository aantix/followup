class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ApplicationHelper

  def facebook
    oauth
  end

  def google_oauth2
    oauth
  end

  def oauth
    @user = User.find_or_create_for_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?

      #sign_in_and_redirect @user, :event => :authentication # This will throw if @user is not activated
      FollowupJob.perform_later(@user.id, false)

      sign_in @user
      redirect_to emails_path

      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      redirect_to root_url
    end
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

end
