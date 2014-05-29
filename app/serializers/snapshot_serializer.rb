class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :snap_date,
             :staff, :non_billable, :unassignable, :billing, :non_billing,
             :overhead, :assignable, :overallocated, :billable,
             :utilization, :gross_utilization
end
