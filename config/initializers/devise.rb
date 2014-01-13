puts 'No GOOGLE_CLIENT_ID and/or GOOGLE_SECRET specified in ENV' if [ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET']].include? nil

Devise.setup do |config|
  require 'devise/orm/active_record'
  require 'omniauth-google-oauth2'

  config.omniauth :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'], { access_type: "offline", approval_prompt: "" }
  config.secret_key = 'e1978a6557126bfcadeae00d540e2a50b0acd4b66bfa727c234b8eae9ba3f992e7a9e077abdd77552d1621a566bf8bac8a66619b988e9007bbc0f34fc9d2c637'
end
