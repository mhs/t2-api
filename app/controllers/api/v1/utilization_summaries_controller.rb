class Api::V1::UtilizationSummariesController < ApplicationController
  def index
    office_id = params[:office_id].blank? ? nil : params[:office_id].to_i
    snap_date = params[:snap_date].blank? ? nil : Date.parse(params[:snap_date])
    summary_start_date = params[:summary_start_date].blank? ? nil : Date.parse(params[:summary_start_date])
    summary_end_date = params[:summary_end_date].blank? ? nil : Date.parse(params[:summary_end_date])

    summary = UtilizationSummary.new(office_id: office_id,
                                     snap_date: snap_date,
                                     summary_start_date: summary_start_date,
                                     summary_end_date: summary_end_date)

    render json: [summary]
  end
end
