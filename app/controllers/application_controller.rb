class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  def index

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
