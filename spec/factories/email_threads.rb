# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_thread do
    user_id 1
    thread_id "MyString"
    last_email_at "2014-08-19 22:33:21"
    emails_count 1
  end
end
