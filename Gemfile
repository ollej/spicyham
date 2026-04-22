source 'https://rubygems.org'

ruby '4.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '8.1.3'
gem 'bootsnap', require: false

gem 'pg'
gem 'xmlrpc'
gem 'devise'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'lucide-rails'
gem 'gandi_v5'
gem 'psych'
gem 'puma'

group :production do
  gem 'rails_12factor'
end

gem 'propshaft'
gem 'jsbundling-rails'
gem 'cssbundling-rails'
gem 'turbo-rails'

# Needed for Ruby 3.4.x
gem "rexml"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
gem 'public_suffix'

# missing gems
gem 'ostruct'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

group :development do
  gem 'byebug'
  gem 'pry'
  gem 'listen'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end
