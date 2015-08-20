module Mail
  module Adapters
    class GmailAdapter
      attr_reader :user, :total_cached_messages

      FULL_MESSAGE     = 'full'
      METADATA_MESSAGE = 'metadata'  # Headers plus message subject. No message body
      MAX_BATCH        = 1000
      PARAMETERS       = {userId: 'me', labelIds: 'INBOX'}

      def initialize(user, adapter = nil)
        @user = user
        @full_filter_messages = []
        @total_cached_messages = 0
      end

      def messages
        query_message_count
        filter_meta_messages
        filter_full_messages
      end

      private

      def filter_meta_messages
        page = begin
          $google_api_client.execute(api_method: $gmail_api.users.messages.list,
                                     parameters: PARAMETERS,
                                     authorization: auth)
        rescue StandardError => error
          logger.info "!!! filter_meta_messages - #{error.message}"
          logger.info error.backtrace.join("\n")

          sleep 10
          retry
        end

        begin
          batch_messages_for_page page.data.messages, meta_filter, METADATA_MESSAGE

          page = begin
            $google_api_client.execute(api_method: $gmail_api.users.messages.list,
                                       parameters: PARAMETERS.merge({pageToken: page.next_page_token}),
                                       authorization: auth) if page.next_page_token
          rescue StandardError => error
            logger.info "!!! filter_meta_messages - #{error.message}"
            logger.info error.backtrace.join("\n")

            sleep 10
            retry
          end

        end while page.next_page_token
      end

      def filter_full_messages
        # Process full messages in groups of 1,000
        full_filtering_groups = @full_filter_messages.uniq.in_groups_of(MAX_BATCH)

        full_filtering_groups.each do |filtered_messages|
          batch_messages_for_page filtered_messages.compact, full_filter, FULL_MESSAGE
        end
      end

      def query_message_count
        result = $google_api_client.execute(api_method: $gmail_api.users.labels.get, parameters: {userId: 'me', id: 'INBOX'}, authorization: auth)

        @total_count = result.data.messages_total
      end

      def percentage_complete
        ((total_cached_messages / @total_count.to_f) * 100).round
      end

      def full_filter
        Google::APIClient::BatchRequest.new do |message|
          unless Mail::Filters::BodyFilter.filtered?(message.data.payload.parts[1].body.data)

            msg  = Message.new(thread_id: message.data.thread_id,
                               message_id: message.data.id,
                               to_name: to(message).display_name, to_email: to(message).address,
                               from_name: from(message).display_name, from_email: from(message).address,
                               subject: find_header('Subject', message),
                               received_on: find_header('Date', message),
                               plain_body: message.data.payload.parts[0].body.data,
                               html_body: message.data.payload.parts[1].body.data)

            Mail::Adapters::MailAdapter.save_message!(msg)

            total_cached_messages += 1

            logger.info "#{total_cached_messages}) #{message.data.id}"
          end
        end
      end

      def meta_filter
        msg = Struct.new(:id)
        Google::APIClient::BatchRequest.new do |message|
          unless filtered?(message)
            @full_filter_messages << msg.new(message.data.id)
          end
        end
      end

      def filtered?(message)
        EmailThread.exists?(thread_id: message.data.thread_id) ||
            Mail::Filters::FromFilter.filtered?(from(message).address, user.email) ||
            Mail::Filters::HeaderFilter.filtered?(message.data.payload.headers) ||
            Mail::Filters::SubjectFilter.filtered?(find_header('Subject', message))
      end

      # message.data.payload.mimeType
      # => "multipart/alternative"

      # message.data.payload.parts.first.mimeType  => text/plain;text/html
      # message.data.payload.parts.first.body.data =>
      def batch_messages_for_page messages, filter, request_format
        logger.info "Getting a new page of messages"

        messages.each do |message|
          filter.add(api_method: $gmail_api.users.messages.get,
                     parameters: {userId: 'me', id: message.id, format: request_format})
        end

        begin
          $google_api_client.execute(filter, authorization: auth) unless messages.empty?
        rescue StandardError => error
          logger.info "!!! batch_messages_for_page - #{error.message}"
          logger.info error.backtrace.join("\n")

          sleep 10
          retry
        end
      end

      def find_header header_name, message
        message.data.payload.headers.find { |h| h.name.strip.downcase == header_name.downcase }.value
      end

      def from(message)
        email_for(find_header('From', message))
      end

      def to(message)
        email_for(find_header('To', message))
      end

      def email_for e
        raw_addresses = Mail::AddressList.new(e) rescue nil
        if raw_addresses.present? && raw_addresses.addresses.any?
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
        @auth.access_token = user.omniauth_token
        @auth
      end

      def logger
        Rails.logger
      end
    end
  end
end