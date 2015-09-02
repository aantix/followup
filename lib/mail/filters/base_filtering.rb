module Mail
  module Filters
    class BaseFiltering
      attr_reader :filters
      attr_accessor :message

      def initialize
      end

      def filtered?
        invoked_filter = filters.detect{|filter| filter.filtered?}
        self.message   = (invoked_filter || Struct.new(:message).new).message

        invoked_filter.present?
      end

    end
  end
end
