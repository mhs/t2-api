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
    render json: allocation
  end

  # POST /allocations.json
  def create
    allocation = Allocation.new(params[:allocation])
    allocation.creator = current_user
    if allocation.save
      if allocation.person.present?
        with_conflicts = allocation.person.allocations_with_conflicts_for(window_start, window_end)
        new_with_conflicts = with_conflicts.find { |a| a.id == allocation.id } || allocation
        # NOTE: Ember Data wants the new record in the first spot in the array
        with_conflicts = [new_with_conflicts] + (with_conflicts - [new_with_conflicts])
        availabilities = allocation.person.availabilities_for(window_start, window_end).map do |a|
          AvailabilitySerializer.new(a, root: false).as_json
        end
      else
        with_conflicts = allocation
        availabilites = []
      end 
      render json: with_conflicts, meta: availabilities, meta_key: :availabilities, status: :created
    else
      render json: { errors: allocation.errors }, status: :unprocessable_entity
    end
  end

  # PUT /allocations/1.json
  def update
    allocation = Allocation.find(params[:id])
    if allocation.update_attributes(params[:allocation])
      render json: allocation.person.allocations_with_conflicts_for(window_start, window_end), status: :ok
    else
      render json: { errors: allocation.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /allocations/1.json
  def destroy
    allocation = Allocation.find(params[:id])
    person = allocation.person
    allocation.destroy
    render json: person.allocations_with_conflicts_for(window_start, window_end), status: :ok
  end

end
