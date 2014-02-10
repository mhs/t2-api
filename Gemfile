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
gem 'haml'
gem 'acts-as-taggable-on'
gem 'paperclip'
gem 'aws-sdk'
gem 'protected_attributes' # TODO: remove this and replace with strong params

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
  # gem 'pry-plus'
  gem 'taps'
  gem 'sqlite3'
  gem 'foreman'
  gem 'capybara'
  gem 'launchy'
  gem 'byebug'
end

group :production do
    gem 'thin'
end
