source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.13'
gem 'pg'
gem 'active_model_serializers'
gem 'acts_as_paranoid'
gem 'hashie'
gem 'rack-cors', require: 'rack/cors'
gem 'memoist'


group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'pry'
  gem 'pry-debugger'
  gem 'taps'
  gem 'sqlite3'
  gem 'foreman'
end

group :production do
    gem 'thin'
end
