require 'google/api_client'

class User < ActiveRecord::Base
  has_many :email_threads

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  #->Prelang (user_login/devise)
  def self.find_for_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    # The User was found in our database
    return user if user

    # The User was not found and we need to create them
    User.create(name:     auth.extra.raw_info.name,
                provider: auth.provider,
                uid:      auth.uid,
                email:    auth.info.email,
                image_url: auth.info.image,
                password: Devise.friendly_token[0,20],
                omniauth_token: auth.credentials.token,
                omniauth_refresh_token: auth.credentials.refresh_token,
                omniauth_expires_at: Time.at(auth.credentials.expires_at),
                omniauth_expires: auth.credentials.expires)
  end


  def refresh_token!
    if omniauth_expires_at < Time.now
      client = Google::APIClient.new
      client.authorization.client_id = ENV['GOOGLE_APP_ID']
      client.authorization.client_secret = ENV['GOOGLE_SECRET_ID']
      client.authorization.grant_type = 'refresh_token'
      client.authorization.refresh_token = omniauth_refresh_token

      client.authorization.fetch_access_token!

      self.omniauth_expires_at = Time.now + client.authorization.expires_in
      self.omniauth_token = client.authorization.access_token

      save!
    end
  end

  def current_email_threads
    email_threads.where("last_email_at > ?", FollowupWorker::LOOKBACK.days.ago).order("last_email_at desc")
  end


end
