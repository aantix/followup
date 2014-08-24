require 'rack/utils'

class Email < ActiveRecord::Base
  belongs_to :email_thread, dependent: :destroy, counter_cache: true
  has_many :questions, dependent: :destroy
  has_many :email_profile_images, primary_key: :from_email, foreign_key: :email

  HTML        = "text/html"
  TEXT        = "text/plain"
  ALTERNATIVE = "multipart/alternative"

  TYPES       = [HTML, TEXT]

  MAX_LINKS   = 3

  TALON_PATH  = "/usr/bin/python #{Rails.root}/scripts/email_extract/extract_response.py"

  BLACKLISTED_PHRASES   = ['click here', "password reset", "new password",
                           'activate account', 'your login', 'unsubscribe',
                           'manage preferences', 'contact us', "password reset",
                           'stop receiving email', 'stop receiving these', 'change your settings',
                           'dear customer']

  BLACKLISTED_EMAILS    = ['noreply@', 'no-reply@','mailer-daemon@', 'alert@', 'alerts@', 'admin@', 'deploy@',
                           'member@', 'notifications@', 'members@', "jobs-listings@", 'service@']

  BLACKLISTED_SUBJECTS  = ['do not reply', 'donotreply', 'password reset', "confirm subscription"]

  BLACKLISTED_HEADERS   = ['Precedence: bulk?', 'Precedence: list?', 'Precedence: junk?', 'Auto-Submitted: auto-generated']

  BLACKLISTED_LINKS     = ['Privacy', 'Support', 'Blog', 'Legal', 'Terms', 'Terms of Use', 'Facebook', 'Twitter', 'Click Here',
                           'Help Center', 'Security']

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

  def self.html?(message)
    return nil if message.blank?
    message.index(/#{HTML}/i)
  end

  def self.plain_text?(message)
    return nil if message.blank?
    message.index(/#{TEXT}/i)
  end

  def self.filtered?(message, message_body, owner_email)
    return true if message_body.nil?

    blacklisted_email?(from_addresses(message)) ||
        blacklisted_phrases?(message_body) ||
        blacklisted_subject?(message.subject) ||
        blacklisted_header?(message.msg) ||
        too_many_links?(message_body) ||
        no_direct_addressment(to_addresses(message), owner_email)
  end

  def self.no_direct_addressment(emails, owner)
    !emails.any?{|e| e == owner}
  end

  def self.blacklisted_email?(emails)
    emails.any? do |email|
      blacklisted_words?(BLACKLISTED_EMAILS, email)
    end
  end

  def self.blacklisted_phrases?(email_body)
    blacklisted_words?(BLACKLISTED_PHRASES, email_body)
  end

  def self.blacklisted_subject?(subject)
    blacklisted_words?(BLACKLISTED_SUBJECTS, subject)
  end

  def self.blacklisted_header?(message)
    blacklisted_words?(BLACKLISTED_HEADERS, message)
  end

  def self.blacklisted_words?(phrases, text)
    phrases.any?{|phrase| text =~ /#{phrase}/i}
  end

  def self.from_addresses(message)
    addresses(message.from)
  end

  def self.to_addresses(message)
    addresses(message.to)
  end

  def self.addresses(items)
    return [] if items.blank?
    items.collect{|address| "#{address.mailbox}@#{address.host}"}
  end

  def self.too_many_links?(message)
    link_count(message) > MAX_LINKS
  end

  def self.link_count(message)
    doc = Nokogiri::HTML(message, 'utf-8')
    doc.search("a").reject do |a|
      BLACKLISTED_LINKS.any?{|bl| a.text =~ /#{bl}/i}
    end.size
  end
end