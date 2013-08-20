class PtoRequestSerializer < ActiveModel::Serializer
  attributes :id, :notes, :start_date, :end_date, :project_name, :project_id, :person_id
end

