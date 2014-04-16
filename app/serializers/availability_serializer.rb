class AvailabilitySerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :percent_allocated, :person_id
end
