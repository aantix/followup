module Mail
  module Filters
    class MetaFiltering < BaseFiltering
      def initialize(from_address, owner_address, headers, subject)
        @filters = [Mail::Filters::FromFilter.new(from_address, owner_address),
                    Mail::Filters::HeaderFilter.new(headers),
                    Mail::Filters::SubjectFilter.new(subject)]
      end
    end
  end
end
