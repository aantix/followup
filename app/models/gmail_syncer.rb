require 'mail'

class GmailSyncer
  attr_reader :user

  def perform user_id
    @user = User.find user_id
    @total_cached_messages = 0
    query_message_count

    get_next_page
  end

  def query_message_count
    result = $google_api_client.execute(api_method: $gmail_api.users.labels.get,
                                        parameters: {userId: 'me', id: 'INBOX'},
                                        authorization: auth)

    @total_count = result.data.messages_total
  end

  def get_next_page params={}
    params.reverse_merge!(userId: 'me', labelIds: 'INBOX')

    page = $google_api_client.execute(api_method: $gmail_api.users.messages.list,
                                      parameters: params,
                                      authorization: auth)

    cache_messages_for_page page
  end

  def percentage_complete
    ((@total_cached_messages / @total_count.to_f) * 100).round
  end

  def cache_messages_for_page page
    logger.info "Getting a new page of messages"

    batch = Google::APIClient::BatchRequest.new do |message|
      thread  = user.email_threads.find_or_create_by(thread_id: message.data.thread_id)

      return if thread.destroyed?

      cached_message = thread.emails.where(message_id: message.data.id).first_or_initialize

      # begin
        from = email_for(find_header('From', message))
        to   = email_for(find_header('To', message))

        cached_message.update_attributes! from_name: from.display_name,
                                          from_email: from.address,
                                          to_name: to.display_name,
                                          to_email: to.address,
                                          subject: find_header('Subject', message),
                                          received_on: find_header('Date', message)
      # rescue
        logger.error "Could not cache message #{message.data.id} for user #{user.email}"
      # end

      @total_cached_messages += 1

      logger.info "#{@total_cached_messages}) #{message.data.id} -- #{message.data.payload.mime_type}"
    end

    page.data.messages.each do |message|
      batch.add(api_method: $gmail_api.users.messages.get,
                parameters: {userId: 'me', id: message.id, format: 'metadata'})
    end

    $google_api_client.execute(batch, authorization: auth)

    if page.next_page_token
      get_next_page pageToken: page.next_page_token
    end
  end

  def find_header header_name, message
    message.data.payload.headers.find{|h| h.name.strip.downcase == header_name.downcase }.value
  end

  def email_for e
    raw_addresses = Mail::AddressList.new(e)
    if raw_addresses.addresses.any?
      raw_addresses.addresses.first
    else
      address = Struct.new(:address, :display_name)
      address.new("", "")
    end
  end

  def auth
    return @auth if @auth

    user.refresh_token!

    @auth = $google_api_client.authorization.dup
    #@auth.update_token! refresh_token: user.refresh_token!
    #@auth.fetch_access_token!
    @auth.access_token = user.omniauth_token
    @auth
  end

  def logger
    Rails.logger
  end
end