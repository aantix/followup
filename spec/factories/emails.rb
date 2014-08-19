# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    user_id 1
    thread_id 1
    message_id 1
    from "MyString"
    body "MyText"
    received_on "2014-08-18 21:58:33"
  end
end
