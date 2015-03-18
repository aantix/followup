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

sheet_index  = 1
email_index  = 9
name_index   = 2
status_index = 0
exchange_index = 1

cipher = Gibberish::AES.new(ENV["PASSCODE"] || '')
username = cipher.dec("U2FsdGVkX1/YR/zl4AwwGc+t1qMNZo+9/rAbrWeOEN9w7ns5NC/tHzHLedFN\nSN8O\n")
password = cipher.dec("U2FsdGVkX19QII0WU5QHrMGThSN61NW9TCacfOghN0w=\n")

# https://docs.google.com/spreadsheets/d/16uqBE7K21YvLkRHd4kg4HOb6UVlfL8wgQPL5aB5OUUk/edit#gid=1733249771
spreadsheet_id = '16uqBE7K21YvLkRHd4kg4HOb6UVlfL8wgQPL5aB5OUUk'

spreadsheet = GoogleSpreadsheet.login(username, password)
ws       = spreadsheet.spreadsheet_by_key(spreadsheet_id).worksheets[sheet_index]

mail     = Gmail.connect(username, password)
to_email = "test-xyzabc1230"

rows     = ws.rows
entries  = {}

puts "Checking for any companies that haven't been emailed.."
(1..rows.size - 1).each do |i|
  row         = rows[i]

  next if row[status_index] == EMAILED_STATUS

  email       = row[email_index]
  n           = row[name_index]

  email_parts = nil
  begin
    email_parts = Mail::Address.new(email)
  rescue
  	next
  end

  next if email_parts.domain.blank?

  entries[email_parts.domain] = i

  puts "#{i}) #{to_email}@#{email_parts.domain}"

	mail.deliver do
	  to "#{to_email}@#{email_parts.domain}"
	  subject "Hello?"
	  body "Did you send the doc?"
	  row[status_index] = EMAILED_STATUS
	end  

	ws.save

end



puts "Now checking for responses.... "

while true
	print "."
  emails = gmail.inbox.emails(gm: "#{to_email}@*")

  emails.each do |email|
  	from_email = Mail::Address.new(email.from)
  	r = entries[from_email.domain] 

    if email.message =~ /Microsoft/i
    	rows[r][exchange_index] = 'yes'
    else
    	rows[r][exchange_index] = 'no'
    end

    # email.delete
  end

  sleep 1
end	