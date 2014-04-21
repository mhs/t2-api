class Api::V1::AllocationsController < ApplicationController
  before_filter :extract_window, only: [:create]

  # GET /allocations.json
  def index
    relation = with_ids_from_params(Allocation.all)
    if (start_date = params[:startDate])
      # TODO: who the hell is using this?
      results = relation.with_start_date(start_date).to_a
    else
      results = relation.to_a
    end
    if params[:window_start_date]
      window_start = Date.parse(params[:window_start_date])
      window_end = Date.parse(params[:window_end_date])
      results.each do |allocation|
        conflicts = allocation.person.conflicts_for(window_start, window_end)
        conflicts.select! { |c| c.allocations.map(&:id).include?(allocation.id) }
        allocation.conflicts = conflicts
      end
    end
    render json: results
  end

  # GET /allocations/1.json
  def show
    allocation = Allocation.find(params[:id])
    # TODO: this is terrible, put it someplace better
    render json: allocation
  end

  # POST /allocations.json
  def create
    allocation = Allocation.new(params[:allocation])
    if allocation.save
      allocation_with_overlaps = AllocationWithOverlaps.new(allocation, window_start: @window_start, window_end: @window_end)
      render json: allocation_with_overlaps.allocations, status: :created
    else
      render json: { errors: allocation.errors }, status: :unprocessable_entity
    end
  end

  # PUT /allocations/1.json
  def update
    allocation = Allocation.find(params[:id])
    if allocation.update_attributes(params[:allocation])
      render json: allocation, status: :ok
    else
      render json: { errors: allocation.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /allocations/1.json
  def destroy
    allocation = Allocation.find(params[:id])
    allocation.destroy
    render json: nil, status: :ok
  end

  private

  def extract_window
    @window_start = Date.parse(params[:allocation].delete(:window_start_date))
    @window_end = Date.parse(params[:allocation].delete(:window_end_date))
  end
end
