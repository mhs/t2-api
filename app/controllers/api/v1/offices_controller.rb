class Api::V1::OfficesController < ApplicationController
  def index
    @offices = with_ids_from_params(Office.includes(:projects, :people))
    render json: @offices
  end

  def show
    @office = Office.find params[:id]
    render json: @office
  end
end
