class AvailabilitySerializer < ActiveModel::Serializer
  attributes :start_date, :end_date, :percent_allocated, :person_id

  self.root = false
end
