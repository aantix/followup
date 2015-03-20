ENV["RAILS_ENV"] ||= "production"

# Must schedule this script to start at or after midnight.
#  It takes the current day plus the time the user has specified
#  and schedules the email updates for that timestamp.
#  E.g. perform_at "2014-09-09 09:00:00 -0700"

root   = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require File.join(root, "config", "environment")

logger = Logger.new(File.open("#{root}/log/schedule_reminders_#{Rails.env}.log", 'w+'))

require 'gmail'
require 'mail'
require 'google_spreadsheet'

EMAILED_STATUS = 'emailed'
INVALID_STATUS = 'invalid'

sheet_index    = 1

email_index    = 9
name_index     = 2
status_index   = 0
exchange_index = 1

cipher = Gibberish::AES.new(ENV["PASSCODE"] || '')
username = cipher.dec("U2FsdGVkX1/YR/zl4AwwGc+t1qMNZo+9/rAbrWeOEN9w7ns5NC/tHzHLedFN\nSN8O\n")
password = cipher.dec("U2FsdGVkX19QII0WU5QHrMGThSN61NW9TCacfOghN0w=\n")

# https://docs.google.com/spreadsheets/d/16uqBE7K21YvLkRHd4kg4HOb6UVlfL8wgQPL5aB5OUUk/edit#gid=1733249771
spreadsheet_id = '16uqBE7K21YvLkRHd4kg4HOb6UVlfL8wgQPL5aB5OUUk'

spreadsheet = GoogleSpreadsheet.login(username, password)
ws       = spreadsheet.spreadsheet_by_key(spreadsheet_id).worksheets[sheet_index]

mail     = Gmail.connect(username, password)
to_email = "abcdefk"

rows     = ws.rows
entries  = {}

puts "Checking for any companies that haven't been emailed.."
(1..rows.size - 1).each do |i|
  print "."
  row         = rows[i]

  next unless row[status_index].blank?
  email       = row[email_index]
  n           = row[name_index]

  ws[i + 1, status_index + 1] = INVALID_STATUS

  email_parts = nil
  begin
    email_parts = Mail::Address.new(email)
  rescue
  	next
  end

  next if email_parts.domain.blank?

  entries[email_parts.domain] = i + 1

  puts
  puts "#{i}) #{to_email}@#{email_parts.domain}"

	email = mail.compose do
	  to "#{to_email}@#{email_parts.domain}"
	  subject "Looking for"
    text_part do
      body "Did you send the doc?"
    end
    html_part do
      content_type 'text/html; charset=UTF-8'
      body "<p>Did you send the doc?</p>"
    end
  end
  email.deliver!

  ws[i + 1, status_index + 1] = EMAILED_STATUS

end

ws.save

puts
puts
puts "Now checking for responses.... "

while true
	print "."
  emails = mail.inbox.find(search: "#{to_email}@*")

  emails.each do |email|
    domain = email.from.first.host rescue nil

    # Deeper search of message body in case from wasn't specified
    domain = entries.find {|(k, v)| email.body =~ /#{k}/i} if domain.blank?

    if domain.nil?
      email.delete!
      next
    end

  	row    = entries[domain.first]

    puts
    puts "-------------------"
    puts domain.inspect
    puts row
    puts email.subject
    puts "-------------------"
    puts

    exchange = email.message =~ /Microsoft/i ? 'yes' : 'no'
    ws[row][exchange_index + 1] = exchange

    ws.save

    email.delete!
  end


  sleep 1
end