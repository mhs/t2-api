class SnapshotSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :utilization, :snap_date
  has_many :staff
  has_many :overhead
  has_many :billable
  has_many :unassignable
  has_many :assignable
  has_many :billing
  has_many :non_billing
end
