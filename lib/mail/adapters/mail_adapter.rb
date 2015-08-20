module Mail
  module Adapters
    class MailAdapter
      attr_reader :adapter, :user
      delegate :messages, to: :adapter

      def initialize(user, adapter = nil)
        @user    = user
        @adapter = (adapter || default_adapter).new(user)
      end

      def self.save_message!(message)
        thread = user.email_threads.find_or_create_by(thread_id: message.thread_id)

        return if thread.destroyed?

        cached_message = thread.emails.where(message_id: message.message_id).first_or_initialize

        begin
          cached_message.update_attributes! from_name: message.from_name,
                                            from_email: message.from_email,
                                            to_name: message.to_name,
                                            to_email: message.to_email,
                                            subject: message.subject,
                                            received_on: message.received_on,
                                            html_body: message.html_body,
                                            plain_body: message.plain_body
        rescue
          logger.error "Could not cache message #{message.data.id} for user #{user.email}"

        end
      end

      private

      def default_adapter
        Mail::Adapters::GmailAdapter
      end

    end
  end
end