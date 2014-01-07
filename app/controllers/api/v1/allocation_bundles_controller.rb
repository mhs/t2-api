class Api::V1::AllocationBundlesController < ApplicationController

  def index
    start_date = Date.parse params[:start_date]
    end_date = Date.parse params[:end_date]
    bundle = AllocationBundle.new(start_date, end_date)
    render json: [bundle]
  end

end
