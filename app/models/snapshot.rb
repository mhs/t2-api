class Snapshot < ActiveRecord::Base

  extend Memoist

  serialize :staff_ids
  serialize :overhead_ids
  serialize :billable_ids
  serialize :unassignable_ids
  serialize :assignable_ids
  serialize :billing_ids
  serialize :non_billing_ids

  attr_accessible :snap_date, :utilization, :office_id
  belongs_to :office
  scope :from_today, lambda { where(snap_date: Date.today) }

  def self.today!
    snap = new snap_date: Date.today, office_id: nil
    snap.capture_data
    snap.save!
    snap
  end

  def self.today
    from_today.order("created_at ASC").last
  end

  %w{ assignable billing non_billing overhead billable unassignable staff }.each do |method_name|
    define_method method_name do
      Person.where(id: send("#{method_name}_ids"))
    end
    memoize method_name
  end

  alias_method :people, :staff

  def capture_data
    self.staff_ids = Person.currently_employed.map(&:id)
    self.overhead_ids = Person.overhead.currently_employed.map(&:id)
    self.billable_ids = Person.billable.currently_employed.map(&:id)
    self.unassignable_ids = Person.unassignable_today.map(&:id)
    self.assignable_ids = billable_ids - unassignable_ids
    self.billing_ids = Person.billing_today.map(&:id)
    self.non_billing_ids = assignable_ids - billing_ids
    self.utilization = sprintf "%.1f", (100.0 * billing_ids.size) / assignable_ids.size
  end

end
