require 'mixpanel-ruby'

module Mixpanel
  MIXPANEL = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
end