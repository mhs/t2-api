class Api::V1::SnapshotsController < ApplicationController
  def index
    @snapshots = Snapshot.all
    render json: @snapshots
  end

  def show
    @snapshot = Snapshot.find params[:id]
    render json: @snapshot
  end
end
