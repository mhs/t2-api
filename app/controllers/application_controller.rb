class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  def after_sign_in_path_for(user)
    # Holy fuck
    url = URI.parse(session[:return_url] || 'http://t2.neo.com')
    token = [['authentication_token',user.authentication_token]]
    url.query = URI.encode_www_form(URI.decode_www_form(url.query || "") + token)
    url.to_s
  end

  private
      def get_auth_token
          if auth_token = params[:authentication_token].blank? && request.headers["Authorization"]
              # we're overloading ActiveResource's Basic HTTP authentication here, so we need to
              # do some unpacking of the auth token and re-save it as a parameter.
              params[:authentication_token] = auth_token
          end
      end

end
