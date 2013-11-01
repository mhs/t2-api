class SessionsController < Devise::SessionsController

  layout 'devise/sessions'

  prepend_before_filter :set_return_url, only: [:new]

  def destroy
    current_user.clear_authentication_token!
    super
  end

  def set_return_url
    session[:return_url] = params[:return_url]
  end

end
