require 'cgi'

class Email
  TALON_PATH = "/usr/bin/python #{Rails.root}/scripts/email_extract/extract_response.py"

  def self.extract_body_signature(email_body)
    response = `#{TALON_PATH} \"#{CGI.escapeHTML(email_body)}\"`

    json      = JSON.parse(response)
    body      = json["reply"]
    signature = json["signature"]

    return body, signature
  end

  def self.filtered?(message, owner_email)
    from_addresses = addresses(message.from)
    to_addresses   = addresses(message.to)

    noreply?(from_addresses) || no_direct_addressment(to_addresses, owner_email) || subscription?(message.body)
  end

  def self.noreply?(emails)
    emails.any? {|email| email =~ /noreply/i}
  end

  def self.subscription?(email_body)
    email_body =~ /(unsubscribe|manage preferences|contact us)/i
  end

  def self.no_direct_addressment(emails, owner)
    !emails.any?{|e| e == owner}
  end

  def self.addresses(items)
    items.collect{|address| "#{address.mailbox}@#{address.host}"}
  end
end