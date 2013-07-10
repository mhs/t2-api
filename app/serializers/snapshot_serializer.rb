class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :utilization, :snap_date
end
