module Mixpanel
  extend ActiveSupport::Concern

  module ClassMethods
    def tracker
      @tracker||=Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    end
  end
end