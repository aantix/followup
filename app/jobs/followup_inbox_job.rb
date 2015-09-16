class FollowupInboxJob
# class FollowupInboxJob < ActiveJob::Base
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(user_id)
    @message_count = 0

    user  = User.find(user_id)
    user.refresh_token!

    adapter = Mail::Adapters::GmailAdapter.new(user, count_callback, message_callback)
    adapter.messages
  end

  def count_callback
    Proc.new {|count| total(count)}
  end

  def message_callback
    Proc.new {@message_count+=1; at(@message_count)}
  end
end