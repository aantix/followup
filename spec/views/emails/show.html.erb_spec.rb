require 'rails_helper'

RSpec.describe "emails/show", :type => :view do
  before(:each) do
    @email = assign(:email, Email.create!(
      :user_id => 1,
      :thread_id => 2,
      :message_id => 3,
      :from => "From",
      :body => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/From/)
    expect(rendered).to match(/MyText/)
  end
end
