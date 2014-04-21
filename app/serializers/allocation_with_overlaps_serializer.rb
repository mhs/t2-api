class AllocationWithOverlapsSerializer < ActiveModel::Serializer
  root :allocation

  attributes :id, :notes, :start_date, :end_date,
             :billable, :binding, :provisional, :project_id, :percent_allocated

  has_one :person, embed: :ids, include: true
  has_many :conflicts, embed: :ids, include: true
  # TODO: availabilities

end
