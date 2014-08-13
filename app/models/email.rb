class Email
  TALON_PATH = "#{Rails.root}/scripts/extract_response.py"

  def self.extract_body_signature(email_body)
    response = `#{TALON_PATH} "#{email_body}"`

    json      = JSON.parse(response)
    body      = json["body"]
    signature = json["signature"]

    return body, signature
  end

  def self.filtered?(message, owner_email)
    from_addresses = addresses(message)
    to_addresses   = addresses(message)

    noreply?(from_addresses) || no_direct_addressment(to_addresses, owner_email) || subscription?(email_body)
  end

  def self.noreply?(emails)
    emails.any? {|email| email =~ /noreply/i}
  end

  def subscription?(email_body)
    email_body =~ /(unsubscribe|manage preferences)/i
  end

  def no_direct_addressment(emails, owner)
    !emails.any?{|e| e == owner}
  end

  def self.addresses(items)
    items.collect{|address| "#{address.mailbox}@#{address.host}"}
  end

  def self.questions(body)
    []
  end
end