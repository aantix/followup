module Mail
  module Filters
    class BaseFilter
      attr_reader :filter
      attr_reader :message

      def initialize
        @filter  = nil
        @message = "No filtering occurred"
      end

      def blacklisted_words?(blacklisted_phrases, text)
        filtered(blacklisted_phrases.detect{|phrase| text =~ /#{phrase}/i})
      end

      def blacklisted_key_value?(blacklisted_keys, headers)
        filtered(blacklisted_keys.detect do |(k, v)|
          headers.keys.include?(k) && (header_hash[k] == v || v == :any)
        end)
      end

      def blacklisted_name_value?(blacklisted_keys, headers)
        filtered(blacklisted_keys.detect do |(k, v)|
          headers.any?{|h| h.name == k && (v == :any || h.value == v)}
        end)
      end

      private

      def filtered(result)
        filter  = result
        message = "#{self.class}: '#{filter}' detected" if filter
        result
      end
    end
  end
end
