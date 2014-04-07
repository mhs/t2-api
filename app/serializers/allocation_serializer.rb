class AllocationSerializer < ActiveModel::Serializer
  attributes :id, :notes, :start_date, :end_date,
             :billable, :binding, :provisional, :person_id, :project_id, :percent_allocated

end
