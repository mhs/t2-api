require 'utilization_helper'
require 'weighted_set'

class Snapshot < ActiveRecord::Base

  extend Memoist
  extend UtilizationHelper

  serialize :staff_weights, WeightedSet
  serialize :unassignable_weights, WeightedSet
  serialize :billing_weights, WeightedSet

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

  def self.today
    by_date(Date.today).order("created_at ASC").last
  end

  alias_method :old_office, :office

  def office
    old_office || Office::SummaryOffice.new
  end

  def recalculate!
    capture_data
    save!
  end

  def staff_billable_percents
    people = Person.by_office(queried_office).employed_on_date(snap_date)
    result = {}
    # TODO: this is wrong, will not show people who aren't allocated
    people.each do |person|
      result[person] = person.percent_billable
    end
    WeightedSet.new(result)
  end
  memoize :staff_billable_percents

  def queried_office
    office.id ? office : nil
  end

  def capture_data
    allocation_relation = Allocation.by_office(queried_office).on_date(snap_date).includes(:person)
    calc = WeightCalculator.new(allocation_relation)

    # TODO: need to change the keys on these
    self.staff_weights = munge_weights(staff_billable_percents)
    self.unassignable_weights = munge_weights(calc.unassignable)
    self.billing_weights = munge_weights(calc.billing)
    self.utilization = calculate_utilization
  end

  def calculate_utilization
    if assignable_weights.empty?
      0.0
    else
      sprintf "%.1f", (100.0 * billing_weights.total) / assignable_weights.total
    end
  end

  private

  def munge_weights(weights)
    # convert a WeightedSet with Person objects as keys to the serialization format
    weights.transform_keys { |person| person.name }
  end
end
