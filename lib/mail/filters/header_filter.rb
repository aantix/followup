module Mail
  module Filters
    class HeaderFilter < BaseFilter
      BLACKLISTED_HEADERS = {'Precedence' => 'bulk', 'Precedence' => 'list',
                             'Precedence' => 'junk', 'Auto-Submitted' => 'auto-generated',
                             'List-Unsubscribe' => :any}

      def self.filtered?(headers)
        if headers.is_a?(Hash)
          blacklisted_key_value?(BLACKLISTED_HEADERS, headers)
        else
          blacklisted_name_value?(BLACKLISTED_HEADERS, headers)
        end
      end
    end
  end
end
