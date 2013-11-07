class AllocationSerializer < ActiveModel::Serializer
  attributes :id, :notes, :start_date, :end_date, :billable, :binding, :slot_id, :person_id, :project_id

end
