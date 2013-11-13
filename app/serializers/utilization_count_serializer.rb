class UtilizationCountSerializer < ActiveModel::Serializer
  attributes :staff_count, :overhead_count, :billing_count,
    :unassignable_count, :billable_count, :assignable_count,
    :non_billing_count, :date, :office_id, :id

end
