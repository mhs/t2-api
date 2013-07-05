class SlotSerializer < ActiveModel::Serializer
  attributes :id, :start_date, :end_date, :project_id
end
