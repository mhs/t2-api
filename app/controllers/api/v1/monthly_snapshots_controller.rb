class Api::V1::MonthlySnapshotsController < Api::V1::BaseController
  def index
    @snapshots = MonthlySnapshot.one_per_month
    render json: @snapshots
  end

  def show
    @snapshot = MonthlySnapshot.find params[:id]
    render json: @snapshot
  end
end
