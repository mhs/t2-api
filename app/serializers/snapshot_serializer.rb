class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :snap_date, :utilization, :staff_weights,
    :unassignable_weights, :assignable_weights, :billing_weights, :non_billing_weights, :office_id

  embed :ids, include: true

  has_many :people
end
