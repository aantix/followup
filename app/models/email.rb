require 'rack/utils'

class Email < ActiveRecord::Base
  #acts_as_paranoid

  belongs_to :email_thread, counter_cache: true
  has_many :questions, dependent: :destroy
  has_many :email_profile_images, primary_key: :from_email, foreign_key: :email

  MAX_DISPLAY_LENGTH    = 300

  after_create :update_last_email_at

  def active_profile_images
    email_profile_images.where(active: true)
  end

  def update_last_email_at
    email_thread.last_email_at = self.received_on
    email_thread.save!
  end

end