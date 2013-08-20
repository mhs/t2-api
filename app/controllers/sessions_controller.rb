class SessionsController < Devise::SessionsController

  def new
    session[:return_url] = params[:return_url]
    super
  end

end
