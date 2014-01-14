require 'utilization_helper'
class Snapshot < ActiveRecord::Base

  extend Memoist
  extend UtilizationHelper

  # TODO: remove these, or set them up in the migration
  serialize :staff_ids
  serialize :overhead_ids
  serialize :billable_ids
  serialize :unassignable_ids
  serialize :assignable_ids
  serialize :billing_ids
  serialize :non_billing_ids

  serialize :staff_weights
  serialize :unassignable_weights
  serialize :billing_weights

  def assignable_weights
    (staff_weights - unassignable_weights).compact
  end
  memoize :assignable_weights

  def non_billing_weights
    (assignable_weights - billing_weights).compact
  end
  memoize :non_billing_weights

  attr_accessible :snap_date, :utilization, :office_id
  belongs_to :office
  scope :by_date, lambda {|date| where(snap_date: date) }
  scope :by_office_id, lambda {|office_id| where(office_id: office_id) }
  scope :future, lambda { where('snap_date >= ?', Date.today) }
  validates_uniqueness_of :snap_date, scope: :office_id

  def self.one_per_day(office_id=nil)
    snaps = {}
    Snapshot.order("snap_date ASC").by_office_id(office_id).each do |snap|
      snaps[snap.snap_date] = snap
    end
    snaps.values
  end

  def self.on_date(date, office_id=nil)
    by_date(date).by_office_id(office_id).first
  end

  def self.on_date!(date, office_id=nil)
    snap_scope = by_date(date).by_office_id(office_id)
    snap_scope.first_or_initialize.tap do |snap|
      break snap unless snap.new_record?
      snap.capture_data
      snap.save!
    end
  end

  def self.for_weekdays_between!(start_date, end_date, office_id=nil)
    week_days_between(start_date, end_date).map { |d| on_date! d, office_id }
  end

  def self.today!
    on_date!(Date.today)
  end

  alias_method :old_office, :office

  def office
    old_office || Office::SummaryOffice.new
  end


  def self.today
    by_date(Date.today).order("created_at ASC").last
  end

  # TODO: do we still need this?
  %w{ assignable billing non_billing overhead billable unassignable staff }.each do |method_name|
    define_method method_name do
      Person.where(id: send("#{method_name}_ids"))
    end
    memoize method_name
  end

  alias_method :people, :staff

  def recalculate!
    capture_data
    save!
  end

  def capture_data
    queried_office = office.id ? office : nil
    calc = WeightCalculator.new(snap_date, queried_office)

    # TODO: need to change the keys on these
    self.staff_weights = calc.staff
    self.unassignable_weights = calc.unassignable
    self.billing_weights = calc.billing
    self.utilization = calculate_utilization
  end

  def calculate_utilization
    if assignable_weights.empty?
      0.0
    else
      sprintf "%.1f", (100.0 * billing_weights.total) / assignable_weights.total
    end
  end
end
