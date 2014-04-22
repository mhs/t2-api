class Api::V1::AllocationsController < Api::V1::BaseController

  # GET /allocations.json
  def index
    results = with_ids_from_params(Allocation.all)
    if window_start
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
      allocation_with_overlaps = AllocationWithOverlaps.new(allocation, window_start: window_start, window_end: window_end)
      render json: allocation_with_overlaps.allocations, status: :created
    else
      render json: { errors: allocation.errors }, status: :unprocessable_entity
    end
  end

  # PUT /allocations/1.json
  def update
    allocation = Allocation.find(params[:id])
    if allocation.update_attributes(params[:allocation])
      allocation_with_overlaps = AllocationWithOverlaps.new(allocation, window_start: window_start, window_end: window_end)
      render json: allocation_with_overlaps.allocations, status: :ok
    else
      render json: { errors: allocation.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /allocations/1.json
  def destroy
    allocation = Allocation.find(params[:id])
    person = allocation.person
    allocation.destroy
    live_allocation = person.allocations.within(window_start, window_end).first
    if live_allocation
      allocation_with_overlaps = AllocationWithOverlaps.new(live_allocation, window_start: window_start, window_end: window_end)
      render json: allocation_with_overlaps.allocations, status: :ok
    else
      render json: nil, status: :ok
    end
  end

end
