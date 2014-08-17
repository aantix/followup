require 'rack/utils'

class Email
  HTML       = "text/html"
  TEXT       = "text/plain"

  TYPES      = [HTML, TEXT]

  TALON_PATH = "/usr/bin/python #{Rails.root}/scripts/email_extract/extract_response.py"

  BLACKLISTED_PHRASES   = ['click here', "password reset", "new password",
                           'activate account', 'your login', 'unsubscribe',
                           'manage preferences', 'contact us', "password reset",
                           'stop receiving email']

  BLACKLISTED_EMAILS    = ['noreply', 'no-reply','mailer-daemon', 'alert', 'alerts']

  BLACKLISTED_SUBJECTS  = ['do not reply', 'donotreply', 'password reset', "confirm subscription"]

  def self.extract_body_signature(email_body)
    #body = html?(email_body) ? extract_html(email_body) : email_body
    #return nil, nil if body.nil?

    response  = `#{TALON_PATH} \"#{content_type(email_body)}\" \"#{Rack::Utils.escape_html(email_body)}\"`

    if response.present?

      json      = JSON.parse(response)
      body      = json["reply"]
      signature = json["signature"]

      return body, signature
    end

    return nil, nil
  end

  def self.extract_html(message_body)
    message_body.match(/<body.*>.*<\/body>/)[1]
  rescue => e
    puts "----------------------------------"
    puts message_body
    nil
  end

  # Find the first content type listed, as that most likely is the outer envelope and
  #  represents the reply
  def self.content_type(message)
    html = html?(message)
    text = plain_text?(message)

    if html && text
      return html < text ? HTML : TEXT
    end

    html ? HTML : TEXT
  end

  def self.html?(message)
    message.index(/#{HTML}/i)
  end

  def self.plain_text?(message)
    message.index(/#{TEXT}/i)
  end

  def self.filtered?(message, message_body, owner_email)
    blacklisted_email?(from_addresses(message)) ||
        blacklisted_phrases?(message_body) ||
        blacklisted_subject?(message.subject) ||
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
    items.collect{|address| "#{address.mailbox}@#{address.host}"}
  end
end