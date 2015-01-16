class AllocationSerializer < ActiveModel::Serializer
  attributes :id, :notes, :start_date, :end_date,
             :billable, :binding, :person_id, :project_id,
             :percent_allocated, :likelihood, :role

  has_many :conflicts, embed: :ids, include: true
end
