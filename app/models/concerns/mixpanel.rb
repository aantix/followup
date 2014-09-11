puts "hi"
module Mixpanel
  extend ActiveSupport::Concern

  included do
    puts "included!"
  end

  module ClassMethods
    def tracker
      @tracker||=Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    end
  end
end