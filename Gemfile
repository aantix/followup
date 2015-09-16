source 'https://rubygems.org'

ruby '2.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'

gem 'rails', github: "rails/rails", ref: "2ea95a522a058183c27552d78722ed52716b3b13"
gem 'arel', github: "rails/arel"

gem 'devise', github: 'plataformatec/devise'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem "jquery-rails"
gem 'turbolinks', github: 'rails/turbolinks'
gem 'rails_12factor'
gem 'puma'

gem 'mysql2'
gem 'truncate_html'

gem 'gibberish'

# Need to bump the mail gem to 2.5.4 to make it compaitble with Rails and gmail gem
# https://github.com/nu7hatch/gmail/pull/114
gem 'gmail', git: 'https://github.com/aantix/gmail.git'
gem 'google-api-client', require: 'google/api_client'
#gem 'gmail', path: '../gmail'

gem 'tactful_tokenizer'
gem 'sanitize'
gem 'mail'

gem 'sinatra', '>= 1.3.0', :require => nil
gem 'slim'

gem 'mixpanel-ruby'

gem 'bootstrap-sass'

gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'will_paginate'
gem 'possible_email', git: "https://github.com/aantix/possible-email.git"

gem 'sidekiq'
gem 'sidekiq-status', git: "https://github.com/utgarda/sidekiq-status.git"

gem 'thread'
gem 'sidekiq-benchmark'

gem 'font-awesome-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'bundler'

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'rails_config'
gem 'validates_formatting_of'
gem 'tzinfo-data'
gem 'nokogiri'

gem 'record_tag_helper', git: "https://github.com/rails/record_tag_helper.git"

gem 'carrierwave'
gem 'cloudinary'
gem 'google-spreadsheet-ruby'
gem 'google_drive', '0.3.9'

gem 'premailer-rails'
#gem "paranoia", git: 'https://github.com/radar/paranoia.git', branch: "rails4"

group :development do
  gem 'quiet_assets'
  gem 'spring', '1.3.4'
end

group :development, :test do
  gem 'crack'
  gem 'ap'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'pry'
end

group :production do
  gem 'pg'
  gem 'rollbar'
  gem 'unicorn'
end

group :test do
  gem 'webmock'
  gem 'shoulda-matchers'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'vcr'
end