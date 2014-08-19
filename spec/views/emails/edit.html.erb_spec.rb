require 'rails_helper'

RSpec.describe "emails/edit", :type => :view do
  before(:each) do
    @email = assign(:email, Email.create!(
      :user_id => 1,
      :thread_id => 1,
      :message_id => 1,
      :from => "MyString",
      :body => "MyText"
    ))
  end

  it "renders the edit email form" do
    render

    assert_select "form[action=?][method=?]", email_path(@email), "post" do

      assert_select "input#email_user_id[name=?]", "email[user_id]"

      assert_select "input#email_thread_id[name=?]", "email[thread_id]"

      assert_select "input#email_message_id[name=?]", "email[message_id]"

      assert_select "input#email_from[name=?]", "email[from]"

      assert_select "textarea#email_body[name=?]", "email[body]"
    end
  end
end
