class Api::V1::SlotsController < ApplicationController
  def index
    @slots = Slot.all
    render json: @slots
  end

  def show
    @slot = Slot.find params[:id]
    render json: @slot
  end
end
