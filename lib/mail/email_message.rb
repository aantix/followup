module Mail
  class EmailMessage
    HTML        = "text/html"
    TEXT        = "text/plain"
    ALTERNATIVE = "multipart/alternative"
    TYPES       = [HTML, TEXT]

    attr_reader :thread_id, :message_id, :subject
    attr_reader :to_name, :to_email
    attr_reader :from_name, :from_email
    attr_reader :html_body, :plain_body, :headers
    attr_reader :received_on, :filtered, :filtered_message

    def initialize(properties)
      @thread_id   = properties[:thread_id]
      @message_id  = properties[:message_id]
      @subject     = properties[:subject]

      @to_name     = properties[:to_name]
      @to_email    = properties[:to_email]

      @from_name   = properties[:from_name]
      @from_email  = properties[:from_email]

      @html_body   = properties[:html_body]
      @plain_body  = properties[:plain_body]

      @headers     = properties[:headers]
      @received_on = properties[:received_on]

      @filtered         = properties[:filtered]
      @filtered_message = properties[:filtered_message]
    end
  end
end