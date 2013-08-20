require 'devise/orm/active_record'

puts 'No GOOGLE_CLIENT_ID and/or GOOGLE_SECRET specified in ENV' if [ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET']].include? nil

Devise.setup do |config|
  require 'omniauth-google-oauth2'
  config.omniauth :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'], { access_type: "offline", approval_prompt: "" }
  config.token_authentication_key = :authentication_token
end
