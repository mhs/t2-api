class Api::V1::OfficesController < ApplicationController
  def index
    @offices = Office.includes(:projects, :people).all
    render json: @offices
  end

  def show
    @office = Office.find params[:id]
    render json: @office
  end
end
