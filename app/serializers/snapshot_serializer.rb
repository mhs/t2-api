class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :snap_date, :utilization, :staff_ids, :overhead_ids, :billable_ids, :unassignable_ids, :assignable_ids, :billing_ids, :non_billing_ids
  embed :ids, include: true
  has_many :people
end
