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
gem 'octicons_helper'
gem 'uglifier'
gem 'gandi_v5'
gem 'psych'
gem 'puma'

group :production do
  gem 'rails_12factor'
end

# Use webpacker for assets
gem "webpacker", "~> 5.4.4"

# Needed for Ruby 3.4.x
gem "rexml"

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
#gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

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
