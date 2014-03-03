source 'https://rubygems.org'

ruby '2.0.0'

gem 'rake'
gem 'rails_12factor', group: :production
gem 'rails', '~> 4.0'
gem 'pg'
gem 'active_model_serializers'
gem 'paranoia', '~> 2.0'
gem 'hashie'
gem 'rack-cors', require: 'rack/cors'
gem 'memoist'
gem 'devise'
gem 'omniauth-google-oauth2'
gem 'haml', '~> 4.0.5'
gem 'acts-as-taggable-on'
gem 'paperclip'
gem 'aws-sdk'
gem 'protected_attributes'
gem 'bourbon', '~> 3.1.8'
gem 'bitters', '~> 0.9.2'
gem 'nokogiri', '~> 1.6.1'
gem 'premailer-rails', '~> 1.7.0'
gem 'heroku'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'validates_timeliness'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'pry-rails'
  gem 'taps'
  gem 'sqlite3'
  gem 'foreman'
  gem 'capybara'
  gem 'launchy'
  gem 'awesome_print'
  gem 'byebug'
  gem 'railroady'
  gem 'letter_opener'
end

group :development, :staging do
  gem 'mail_safe', '~>0.3.1'
end

group :production do
  gem 'thin'
end
