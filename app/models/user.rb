require 'google/api_client'
require 'concerns/mixpanel'

class User < ActiveRecord::Base
  include Mixpanel

  has_many :email_threads
  has_many :email_profile_images, primary_key: :email, foreign_key: :email
  has_many :emails, through: :email_threads


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  after_create :find_profile_image

  def self.find_or_create_for_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    # The User was found in our database
    if user
      tracker.track(user.id, 'User signed in')
      return user
    end

    # The User was not found and we need to create them
    user = User.create(name:     auth.extra.raw_info.try(:name),
                first_name: auth.extra.raw_info.try(:family_name),
                given_name: auth.extra.raw_info.try(:given_name),
                provider: auth.provider,
                uid:      auth.uid,
                email:    auth.info.email,
                image_url: auth.info.image,
                password: Devise.friendly_token[0,20],
                omniauth_token: auth.credentials.token,
                omniauth_refresh_token: auth.credentials.refresh_token,
                omniauth_expires_at: Time.at(auth.credentials.expires_at),
                omniauth_expires: auth.credentials.expires)

    tracker.track(user.id, 'User created')

    user
  end

  def active_profile_images
    email_profile_images.where(active: true)
  end

  def profile_image_url
    if active_profile_images.size > 0
      active_profile_images.first.image_url(:bright_face_small)
    else
      ActionController::Base.helpers.image_path("default-profile.jpg")
    end
  end

  def refresh_token!
    if omniauth_expires_at < Time.now
      client = Google::APIClient.new
      client.authorization.client_id = ENV['GOOGLE_APP_ID']
      client.authorization.client_secret = ENV['GOOGLE_SECRET_ID']
      client.authorization.grant_type = 'refresh_token'
      client.authorization.refresh_token = omniauth_refresh_token

      begin
        client.authorization.fetch_access_token!
      rescue => e
        Rollbar.report_exception(e, {}, {user_id: self.id})
      end

      self.omniauth_expires_at = Time.now + client.authorization.expiry.minutes
      self.omniauth_token = client.authorization.access_token

      save!
    end
  end

  def current_email_threads
    email_threads.where("last_email_at > ?", FollowupJob::DISPLAY_LOOKBACK.days.ago).order("last_email_at desc")
  end

  def find_profile_image
    FollowupProfileInfoJob.perform_later(self.email)
  end

end
