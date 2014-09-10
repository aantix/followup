require 'mixpanel-ruby'

module Mixpanel
  TRACKER = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
end