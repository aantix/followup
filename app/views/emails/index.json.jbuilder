json.array!(@emails) do |email|
  json.extract! email, :id, :user_id, :thread_id, :message_id, :from, :body, :received_on
  json.url email_url(email, format: :json)
end
