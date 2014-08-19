require 'rails_helper'

RSpec.describe "emails/index", :type => :view do
  before(:each) do
    assign(:emails, [
      Email.create!(
        :user_id => 1,
        :thread_id => 2,
        :message_id => 3,
        :from => "From",
        :body => "MyText"
      ),
      Email.create!(
        :user_id => 1,
        :thread_id => 2,
        :message_id => 3,
        :from => "From",
        :body => "MyText"
      )
    ])
  end

  it "renders a list of emails" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "From".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
