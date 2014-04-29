class Api::V1::ConflictsController < Api::V1::BaseController

  def index
    # conflict ids are in params[:ids]
    conflicts = []
    params[:ids].each do |id|
      person_id, start_date, end_date, _, *allocation_ids = id.split('_')
      person = Person.find(person_id)
      allocations = person.allocations.find(allocation_ids)
      conflicts += person.conflicts_for(Date.parse(start_date), Date.parse(end_date), allocations)
    end
    render json: conflicts
  end

end
