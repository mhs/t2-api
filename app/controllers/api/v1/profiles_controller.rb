class Api::V1::ProfilesController < ApplicationController

  skip_before_filter :verify_authenticity_token

  before_filter :fetch_person

  def update
    render json: @person, status: @person.update_attributes(params[:person]) ? 200 : 400
  end

  private

  def fetch_person
    @person = current_user.person
  end
end
