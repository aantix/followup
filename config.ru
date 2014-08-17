# This file is used by Rack-based servers to start the application.
Encoding.default_external = Encoding::UTF_8

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
