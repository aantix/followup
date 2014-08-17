source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.4'
gem 'mysql2'

# Need to bump the mail gem to 2.5.4 to make it compaitble with Rails and gmail gem
# https://github.com/nu7hatch/gmail/pull/114
#gem 'gmail', git: 'https://github.com/aantix/gmail.git'
gem 'gmail', path: '../gmail'

gem 'sass-rails', '~> 4.0.3'

gem 'tactful_tokenizer'
gem 'sanitize'
gem 'mail'

gem 'bootstrap-sass'

gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'bundler'

gem 'devise', github: 'plataformatec/devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'google-api-client'
gem 'rails_config'
gem 'validates_formatting_of'
gem 'tzinfo-data'

group :development, :test do
  gem 'crack'
  gem 'ap'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'pry'
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  gem 'shoulda-matchers'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'vcr'
end