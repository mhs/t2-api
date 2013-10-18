class Api::V1::ProfilesController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def update
    render json: current_user.person, status: current_user.person.update_attributes(params[:person]) ? 200 : 400
  end
end
