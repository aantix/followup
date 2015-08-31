module Mail
  module Filters
    class SubjectFilter < BaseFilter
      BLACKLISTED_SUBJECTS  = ['do not reply', 'donotreply',
                               'password reset', 'confirm subscription',
                               'invited you']

      attr_reader :subject

      def initialize(subject)
        @subject = subject
      end

      def filtered?
        blacklisted_words?(BLACKLISTED_SUBJECTS, subject)
      end
    end
  end
end
