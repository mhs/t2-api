require 'utilization_helper'
require 'weighted_set'

class Snapshot < ActiveRecord::Base

  extend Memoist
  extend UtilizationHelper

  serialize :staff_weights, WeightedSet
  serialize :unassignable_weights, WeightedSet
  serialize :billing_weights, WeightedSet

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

  def recalculate!
    calculate
    save!
  end

  def people
    Person.by_office(queried_office).employed_on_date(snap_date)
  end

  def queried_office
    office.id ? office : nil
  end

  def calculate
    utilization_group = UtilizationGroup.new(people, snap_date)

    self.staff_weights        = munge_weights(utilization_group.fetch(:billable_percentage))
    self.unassignable_weights = munge_weights(utilization_group.fetch(:unassigned_percentage))
    self.billing_weights      = munge_weights(utilization_group.fetch(:billing_percentage))
    self.utilization          = utilization_group.utilization_percentage
  end

  private

  def munge_weights(weights)
    # convert a WeightedSet with Person objects as keys to the serialization format
    weights.transform_keys { |person| person.name }
  end
end
