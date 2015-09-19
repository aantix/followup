module Mail
  module Adapters
    class MailAdapter
      LOOKBACK   = 4
      CLAW_PATH  = "/usr/bin/python #{Rails.root}/scripts/email_extract/extract_response.py"

      attr_reader :adapter, :user
      delegate :messages, to: :adapter

      def initialize(user, adapter = nil)
        @user    = user
        @adapter = (adapter || default_adapter).new(user)
      end

      def save_message!(user, message)
        thread = user.email_threads.find_or_create_by(thread_id: message.thread_id)

        return if thread.destroyed?

        cached_message = thread.emails.where(message_id: message.message_id).first_or_initialize

        cached_message.update_attributes! from_name: message.from_name,
                                          from_email: message.from_email,
                                          to_name: message.to_name,
                                          to_email: message.to_email,
                                          subject: message.subject,
                                          received_on: message.received_on,
                                          html_body: message.html_body,
                                          plain_body: message.plain_body,
                                          filtered: message.filtered,
                                          filtered_message: message.filter_message
      end

      def extract_body(content_type, quoted_body)
        response  = `#{CLAW_PATH} \"#{content_type}\" \"#{Rack::Utils.escape_html(quoted_body)}\"` || {}
        JSON.parse(response)["reply"]
      end

      private

      def default_adapter
        Mail::Adapters::GmailAdapter
      end

    end
  end
end