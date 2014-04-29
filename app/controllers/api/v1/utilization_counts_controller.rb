class Api::V1::UtilizationCountsController < Api::V1::BaseController
  def index
    office_id = params[:office_id].to_i
    office_id = nil if office_id == 0
    start_date = Date.parse params[:start_date]
    end_date = Date.parse params[:end_date]
    utilizations = UtilizationCount.for_weekdays_between(start_date, end_date, office_id)

    render json: utilizations
  end
end
