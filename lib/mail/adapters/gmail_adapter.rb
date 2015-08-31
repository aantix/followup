module Mail
  module Adapters
    class GmailAdapter < MailAdapter
      include Retryable

      attr_reader :user, :total_cached_messages, :full_filter_messages

      FULL_MESSAGE     = 'full'
      METADATA_MESSAGE = 'metadata'  # Headers plus message subject. No message body
      MAX_BATCH        = 1000

      def initialize(user)
        @user = user
        @full_filter_messages = []
        @total_cached_messages = 0
      end

      def messages
        query_message_count

        filter_full_messages if filter_meta_messages
      end

      private

      def parameters
        @lookback||=4.days.ago.to_date
        @parameters||={userId: 'me', labelIds: 'INBOX', q: "after:#{@lookback.year}/#{@lookback.month}/#{@lookback.day}"}
      end

      def filter_meta_messages
        page = begin
          message_list
        rescue StandardError
          retry_it? ? retry : (return false)
        end

        begin
          batch_messages_for_page page.data.messages, meta_filter, METADATA_MESSAGE

          page = begin
            message_list(pageToken: page.next_page_token) if page.next_page_token
          rescue StandardError
            retry_it? ? retry : (return false)
          end

        end while page.present? && page.next_page_token
        true
      end

      def message_list(params = {})
        $google_api_client.execute(api_method: $gmail_api.users.messages.list,
                                   parameters: parameters.merge(params),
                                   authorization: auth)
      end

      def label_list(params = {})
        $google_api_client.execute(api_method: $gmail_api.users.labels.get,
                                   parameters: parameters.merge(params),
                                   authorization: auth)
      end

      def filter_full_messages
        # Process full messages in groups of 1,000
        full_filtering_groups = full_filter_messages.uniq.in_groups_of(MAX_BATCH)

        full_filtering_groups.each do |filtered_messages|
          batch_messages_for_page filtered_messages.compact, full_filter, FULL_MESSAGE
        end
      end

      def query_message_count
        result       = label_list(id: 'INBOX')
        @total_count = result.data.messages_total
      end

      def percentage_complete
        ((total_cached_messages / @total_count.to_f) * 100).round
      end

      def save_message(message, plain_body, html_body, filtered = false, filter_message = nil)
        msg = Mail::EmailMessage.new(thread_id: message.data.thread_id,
                                     message_id: message.data.id,

                                     to_name: to(message).display_name,
                                     to_email: to(message).address,

                                     from_name: from(message).display_name,
                                     from_email: from(message).address,

                                     subject: find_header('Subject', message),
                                     received_on: find_header('Date', message),

                                     plain_body: plain_body,
                                     html_body: html_body,

                                     filtered: filtered,
                                     filter_message: filter_message)

        save_message!(user, msg)

      end

      def full_filter
        Google::APIClient::BatchRequest.new do |message|
          payload = message.data.payload rescue nil
          if payload.present? && payload.parts.any?
            filter  = body_filtering(message)

            if body_filtering(message).filtered?
              save_message(message, filter.html_body, filter.plain_body, true, filter.message)
            else
              save_message(message, filter.html_body, filter.plain_body)
            end
          end
        end
      end

      def meta_filter
        msg = Struct.new(:id)
        Google::APIClient::BatchRequest.new do |message|
          filter = meta_filtering(message)

          if filter.filtered?
            save_message(message, nil, nil, true, filter.message)
          else
            full_filter_messages << msg.new(message.data.id)
          end
        end
      end

      def meta_filtering(message)
        Mail::Filters::MetaFiltering.new(from(message).address, user.email,
                                         message.data.payload.headers,
                                         find_header('Subject', message))
      end

      def body_filtering(message)
        plain = plain_message(message_json(message))
        html  = html_message(message_json(message))

        Mail::Filters::BodyFiltering.new(html, plain)
      end

      def message_json(message)
        JSON.parse(message.data.to_json)
      end

      def html_message(json)
        extract_body(EmailMessage::HTML, decode_message(message_for(EmailMessage::HTML, json['payload']['parts'])))
      end

      def plain_message(json)
        extract_body(EmailMessage::TEXT, decode_message(message_for(EmailMessage::TEXT, json['payload']['parts'])))
      end

      def decode_message(messages)
        message = messages.first || {'body' => {'data' => ""}}
        Base64.urlsafe_decode64 message['body']['data']
      end

      def message_for(type, json)
        collection = []
        json.each do |message_part|
          if message_part['parts'].present?
            collection.concat(message_for(type, message_part['parts']))
          else
            collection << message_part if message_part['mimeType'] == type
          end
        end
        collection
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
          filtered_message_list(filter) unless messages.empty?
        rescue StandardError => error
          puts "*** Error : #{error.message}"
          puts "*** #{error.backtrace.join("\n")}"

          retry if retry_it?
        end
      end

      def filtered_message_list(filter)
        $google_api_client.execute(filter, authorization: auth)
      end

      def find_header header_name, message
        (message.data.payload.headers.find { |h| h.name.strip.downcase == header_name.downcase } || Struct.new(:value).new).value
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