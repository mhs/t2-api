class AllocationWithOverlapsSerializer < ActiveModel::Serializer
  root :allocation

  attributes :id, :notes, :start_date, :end_date,
             :billable, :binding, :provisional, :person_id, :project_id, :percent_allocated

  has_many :allocations, embed: :ids, include: true
  has_one :person, embed: :ids, include: true
  has_many :conflicts, embed: :ids, include: true
  # TODO: availabilities

end
