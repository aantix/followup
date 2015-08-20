require 'rack/utils'

class Email < ActiveRecord::Base
  #acts_as_paranoid

  belongs_to :email_thread, counter_cache: true
  has_many :questions, dependent: :destroy
  has_many :email_profile_images, primary_key: :from_email, foreign_key: :email

  TALON_PATH  = "/usr/bin/python #{Rails.root}/scripts/email_extract/extract_response.py"
  MAX_DISPLAY_LENGTH    = 300

  after_create :update_last_email_at

  def self.extract_body_signature(content_type, email_body)
    response  = `#{TALON_PATH} \"#{content_type}\" \"#{Rack::Utils.escape_html(email_body)}\"`

    if response.present?

      json      = JSON.parse(response)
      body      = json["reply"]
      signature = json["signature"]

      return body, signature
    end

    return nil, nil
  end

  def active_profile_images
    email_profile_images.where(active: true)
  end

  def update_last_email_at
    email_thread.last_email_at = self.received_on
    email_thread.save!
  end

end