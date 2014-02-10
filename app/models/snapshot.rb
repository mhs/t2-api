require 'utilization_helper'
require 'weighted_set'

class Snapshot < ActiveRecord::Base

  extend Memoist
  extend UtilizationHelper

  serialize :staff_weights, WeightedSet
  serialize :unassignable_weights, WeightedSet
  serialize :billing_weights, WeightedSet

  attr_accessible :snap_date, :utilization, :office_id
  attr_accessor :assignable_weights, :non_billing_weights, :billable

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
      snap.calculate
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

  def recalculate!
    calculate
    save!
  end

  def people
    Person.by_office(office).employed_on_date(snap_date)
  end

  def office
    oid = read_attribute(:office_id)
    oid.present? ? Office.find(oid) : Office::SummaryOffice.new
  end

  def utilization_group
    UtilizationGroup.new(people, snap_date)
  end
  memoize :utilization_group

  def calculate
    self.staff_weights        = person_named_keys(utilization_group.fetch(:billable_percentage))
    self.unassignable_weights = person_named_keys(utilization_group.fetch(:unassigned_percentage)).compact
    self.billing_weights      = person_named_keys(utilization_group.fetch(:billing_percentage)).compact
    self.billable             = staff_weights.compact
    self.non_billing_weights  = person_named_keys(utilization_group.non_billing_weights)
    self.assignable_weights   = person_named_keys(utilization_group.assignable_weights)
    self.utilization          = utilization_group.utilization_percentage
  end


  private

  def person_named_keys(weights)
    # convert a WeightedSet with Person objects to key of Person#name for the serialization format
    weights.transform_keys { |person| person.name }
  end

end
