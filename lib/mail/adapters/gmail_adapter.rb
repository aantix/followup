module Mail
  module Adapters
    class GmailAdapter
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

        puts "-------------------------------------------"
        puts "total_saves = #{@total_saves}"
        puts "total_failed_saves = #{@total_failed_saves.inspect}"
        puts "-------------------------------------------"
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
        result = label_list(id: 'INBOX')
        @total_count = result.data.messages_total
      end

      def percentage_complete
        ((total_cached_messages / @total_count.to_f) * 100).round
      end

      def full_filter
        @total_saves||=0
        @total_failed_saves||=Hash.new(0)

        Google::APIClient::BatchRequest.new do |message|
          # binding.pry if ["14f61ddba89cf3a2", "14f60b9dd2934e22", "14f60abbb6d7052f"].include?(message.data.id)
          payload = message.data.payload rescue return

          if payload.parts.any? && payload.parts.size > 0
            unless Mail::Filters::BodyFilter.filtered?(payload.parts[payload.parts.size - 1].body.data)

              message_json = JSON.parse(message.data.to_json)

              # begin
                plain_body = Base64.urlsafe_decode64(message_json['payload']['parts'][0]['body']['data']) rescue nil
              # rescue => e
                # Looks like some of these emails have parts that have more multiple parts.
                #  Just look
                # binding.pry
              # end
              html_body  = Base64.urlsafe_decode64(message_json['payload']['parts'][1]['body']['data']) rescue nil

              msg  = Mail::EmailMessage.new(thread_id: message.data.thread_id,
                                            message_id: message.data.id,

                                            to_name: to(message).display_name,
                                            to_email: to(message).address,

                                            from_name: from(message).display_name,
                                            from_email: from(message).address,

                                            subject: find_header('Subject', message),
                                            received_on: find_header('Date', message),

                                            plain_body: plain_body,
                                            html_body: html_body)

              @total_saves+=1

              begin
                Mail::Adapters::MailAdapter.save_message!(user, msg)
                "Message saved!"
              rescue
                puts "Message not saved!"
                @total_failed_saves[message.data.id]+=1
              end
              @total_cached_messages += 1

              puts "!!! total_saves = #{@total_saves} -- total_failed_saves = #{@total_failed_saves}"
            end
          end
        end
      end

      def meta_filter
        msg = Struct.new(:id)
        Google::APIClient::BatchRequest.new do |message|
          unless filtered?(message)
            full_filter_messages << msg.new(message.data.id)
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
          filtered_message_list(filter) unless messages.empty?
        rescue StandardError => error
          puts "*** Error : #{error.message}"
          puts "*** #{error.backtrace.join("\n")}"

          retry if retry_it?
        end
      end

      def plain_message(parts)


      end

      def html_message(parts)

      end

      def filtered_message_list(filter)
        $google_api_client.execute(filter, authorization: auth)
      end

      def find_header header_name, message
        message.data.payload.headers.find { |h| h.name.strip.downcase == header_name.downcase }.value.scrub
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