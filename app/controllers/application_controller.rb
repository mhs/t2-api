class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  def after_sign_in_path_for(user)
    # Holy fuck
    url = URI.parse(session[:return_url] || 'http://t2.neo.com')
    token = [['token',user.authentication_token]]
    url.query = URI.encode_www_form(URI.decode_www_form(url.query || "") + token)
    url.to_s
  end
end
