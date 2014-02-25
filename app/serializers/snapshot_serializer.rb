class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :snap_date, :utilization, :staff,
    :unassignable, :assignable, :billing, :non_billing, :office_id
end
