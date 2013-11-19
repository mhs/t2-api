class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  prepend_before_filter :get_auth_token

  def navbar
  end

  def show
    redirect_to after_login_url
  end

  def stored_location_for(user)
    after_login_url
  end

  private

  def after_login_url
    url = session[:return_url].present? ?
                                session[:return_url] :
                                view_context.default_application.url

    # for weird cases (cross-loading from old T2) current_user can get here but not have a token
    current_user.ensure_authentication_token!
    view_context.add_query_param(url, "authentication_token", current_user.authentication_token)
  end

  def get_auth_token
    if auth_token = params[:authentication_token].blank? && request.headers["Authorization"]
      # we're overloading ActiveResource's Basic HTTP authentication here, so we need to
      # do some unpacking of the auth token and re-save it as a parameter.
      params[:authentication_token] = auth_token
    end
  end

  def with_ids_from_params(relation)
    return relation unless params[:ids] && params[:ids].is_a?(Array)
    relation.where(relation.table_name => { id: params[:ids].map(&:to_i) })
  end
end
