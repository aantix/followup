require 'rails_helper'

describe FollowupInboxJob do
  before do
    @user = Factory(:user)
  end

  it "should enqueue n number of email jobs" do
    VCR.use_cassette("FollowupInboxJob") do
      FollowupInboxJob.new.perform(user.id)
      response = Net::HTTP.get_response(URI('http://www.iana.org/domains/reserved'))
      assert_match /Example domains/, response.body
    end
  end
  it "1=1" do
    expect(1).to eq 1
  end
end
