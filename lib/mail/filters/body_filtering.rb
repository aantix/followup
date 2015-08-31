module Mail
  module Filters
    class BodyFiltering < BaseFiltering
      attr_reader :html_body, :plain_body
      def initialize(html_body, plain_body)
        @html_body  = html_body
        @plain_body = plain_body

        @filters = [Mail::Filters::BodyFilter.new(html_body),
                    Mail::Filters::BodyFilter.new(plain_body)]
      end
    end
  end
end
