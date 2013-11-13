class Api::V1::SnapshotsController < ApplicationController
  def index
    office_id = params[:office_id]
    if params[:snap_date].present?
      date = Date.parse params[:snap_date]
      @snapshots = Snapshot.where(office_id: office_id, snap_date: date)
    else
      @snapshots = Snapshot.one_per_day(office_id)
    end
    render json: @snapshots
  end

  def show
    @snapshot = Snapshot.find params[:id]
    render json: @snapshot
  end
end
