class AvailabilitySerializer < ActiveModel::Serializer
  attributes :start_date, :end_date, :person_id

  self.root = false
end
