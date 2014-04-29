class ConflictSerializer < ActiveModel::Serializer

  root :conflicts

  attributes :id, :start_date, :end_date, :percent_allocated, :person_id

  has_many :allocations, embed: :ids

  def person_id
    object.person.id if object.person
  end
end
