module Mail
  module Filters
    class SubjectFilter < BaseFilter
      BLACKLISTED_SUBJECTS  = ['do not reply', 'donotreply', 'password reset', "confirm subscription"]

      def self.filtered?(subject)
        blacklisted_words?(BLACKLISTED_SUBJECTS, subject)
      end

    end
  end
end
