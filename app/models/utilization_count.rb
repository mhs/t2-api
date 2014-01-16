class UtilizationCount
  #find the snapshots for all the weekdays in the given date range
  #for each snapshot make a new UtilizationCount model.
  attr_accessor :staff_count, :overhead_count, :billing_count,
    :unassignable_count, :billable_count, :assignable_count,
    :non_billing_count, :date, :office_id, :id

  def initialize(snapshot)
    @date = snapshot.snap_date
    @staff_count = snapshot.staff_weights.size
    @billable_count = snapshot.staff_weights.total / 100.0
    @overhead_count = @staff_count - @billable_count
    @unassignable_count = snapshot.unassignable_weights.total / 100.0
    @billing_count = snapshot.billing_weights.total / 100.0
    @non_billing_count = snapshot.non_billing_weights.total / 100.0
    @assignable_count = snapshot.assignable_weights.total / 100.0
    @id = snapshot.id
    @office_id = snapshot.office_id
  end

  def self.for_weekdays_between(start_date, end_date, office_id)
    utilizations = Snapshot.for_weekdays_between!(start_date, end_date, office_id).map do |s|
      UtilizationCount.new s
    end
  end

  def active_model_serializer
    UtilizationCountSerializer
  end

  alias read_attribute_for_serialization send

end

