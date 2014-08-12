class Email
  TALON_PATH = "#{Rails.root}/scripts/extract_response.py"

  def self.extract_body_signature(email_body)
    response = `#{TALON_PATH} email_body`

    json      = JSON.parse(response)
    body      = json["body"]
    signature = json["signature"]

    return body, signature
  end
end
