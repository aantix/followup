module Mail
  module Filters
    class BaseFilter
      def self.blacklisted_words?(blacklisted_phrases, text)
        blacklisted_phrases.detect{|phrase| text =~ /#{phrase}/i}
      end

      def self.blacklisted_key_value?(blacklisted_keys, headers)
        blacklisted_keys.detect do |(k, v)|
          headers.keys.include?(k) && (header_hash[k] == v || v == :any)
        end
      end

      def self.blacklisted_name_value?(blacklisted_keys, headers)
        blacklisted_keys.detect do |(k, v)|
          headers.any?{|h| h.name == k && (v == :any || h.value == v)}
        end
      end
    end
  end
end
