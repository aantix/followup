module Mail
  module Filters
    class BaseFiltering
      attr_reader :filters
      attr_accessor :message

      def initialize
      end

      def filtered?
        invoked_filter = filters.detect{|filter| filter.filtered?}
        message        = (invoked_filter || Struct.new(:message).new).message

        invoked_filter
      end

    end
  end
end
