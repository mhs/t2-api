class AllocationSerializer < ActiveModel::Serializer
  attributes :id, :notes, :start_date, :end_date, :billable, :slot_id, :person_id, :project_id

end
