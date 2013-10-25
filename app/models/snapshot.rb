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
  scope :by_date, lambda {|date| where(snap_date: date) }
  scope :by_office_id, lambda {|office_id| office_id ? where(office_id: office_id) : where(false) }

  validates_uniqueness_of :snap_date, scope: :office_id

  def self.one_per_day
    snaps = {}
    Snapshot.order("snap_date ASC").where(office_id: nil).all.each do |snap|
      snaps[snap.snap_date] = snap
    end
    snaps.values
  end

  def self.on_date(date, office_id=nil)
    by_date(date).by_office_id(office_id).first
  end

  def self.on_date!(date, office_id=nil)
    snap = where(snap_date: date, office_id: office_id).first_or_initialize
    snap.capture_data
    snap.save!
    snap
  end

  def self.today!
    on_date!(Date.today)
  end

  def self.today
    by_date(Date.today).order("created_at ASC").last
  end

  %w{ assignable billing non_billing overhead billable unassignable staff }.each do |method_name|
    define_method method_name do
      Person.where(id: send("#{method_name}_ids"))
    end
    memoize method_name
  end

  alias_method :people, :staff

  def capture_data
    self.staff_ids        = Person.by_office(office).employed_on_date(snap_date).map(&:id)
    self.overhead_ids     = Person.by_office(office).overhead.employed_on_date(snap_date).map(&:id)
    self.billable_ids     = Person.by_office(office).billable.employed_on_date(snap_date).map(&:id)
    self.unassignable_ids = Person.unassignable_on_date(snap_date, office).map(&:id)
    self.billing_ids      = Person.billing_on_date(snap_date, office).map(&:id)
    self.assignable_ids   = billable_ids - unassignable_ids
    self.non_billing_ids  = assignable_ids - billing_ids
    self.utilization      = calculate_utilization
  end

  def calculate_utilization
    if assignable_ids.empty?
      0.0
    else
      sprintf "%.1f", (100.0 * billing_ids.size) / assignable_ids.size
    end
  end
end
