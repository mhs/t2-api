class SessionsController < Devise::SessionsController

  layout 'devise/sessions'

  def new
    session[:return_url] = params[:return_url]
    super
  end

  def destroy
    current_user.clear_authentication_token!
    super
  end

end
