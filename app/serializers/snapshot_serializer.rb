class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :snap_date, :staff_ids, :overhead_ids, :billable_ids, :unassignable_ids, :assignable_ids, :billing_ids, :non_billing_ids, :utilization
  has_many :people
  has_one :office, embed: :ids
end
