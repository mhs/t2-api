class Api::V1::SnapshotsController < ApplicationController
  # TODO: deal with provisional allocations
  def index
    office_id = params[:office_id]
    proxy = Snapshot.by_office_id(office_id)
    if params[:snap_date].present?
      date = Date.parse params[:snap_date]
      proxy = proxy.by_date(date)
    end
    render json: proxy.to_a
  end

  def show
    @snapshot = Snapshot.find params[:id]
    render json: @snapshot
  end
end
