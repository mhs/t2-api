class Snapshot < ActiveRecord::Base
  serialize :utilization

  attr_accessible :snap_date, :utilization, :office_id
  belongs_to :office
  scope :from_today, lambda { where(snap_date: Date.today) }

  def self.today!
    create! snap_date: Date.today, office_id: nil, utilization: utilization_data
  end

  def self.today
    from_today.order("created_at ASC").last
  end

  private

  def self.utilization_data

    staff = Person.currently_employed.map(&:name)
    overhead = Person.overhead.currently_employed.map(&:name)
    billable = Person.billable.currently_employed.map(&:name)
    unassignable = Person.unassignable_today.map(&:name)
    assignable = billable - unassignable
    billing = Person.billing_today.map(&:name)
    non_billing = assignable - billing
    utilization = sprintf "%.1f", (100.0 * billing.size) / assignable.size

    {
      staff: staff,
      overhead: overhead,
      billable: billable,
      unassignable: unassignable,
      assignable: assignable,
      billing: billing,
      non_billing: non_billing,
      utilization: utilization
    }
  end
end
