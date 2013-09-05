class ProjectAllowanceSerializer < ActiveModel::Serializer
  attributes :project_id, :person_id, :hours, :available, :used
end
