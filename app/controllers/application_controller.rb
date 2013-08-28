class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  def index
  end

  def navbar
  end

  def stored_location_for(user)
    session[:return_url].present? ?
        view_context.add_query_param(session[:return_url], "authentication_token", user.authentication_token) : 
        view_context.default_application_url
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
