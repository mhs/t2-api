require 'date_range_helper'

class Snapshot < ActiveRecord::Base

  extend Memoist
  extend DateRangeHelper
  include SnapshotFilters

  serialize :staff, FteWeightedSet
  serialize :non_billable, FteWeightedSet
  serialize :unassignable, FteWeightedSet
  serialize :billing, FteWeightedSet
  serialize :assignable, FteWeightedSet
  serialize :non_billing, FteWeightedSet
  serialize :billable, FteWeightedSet
  serialize :overallocated, FteWeightedSet


  attr_accessible :snap_date, :utilization, :office_id

  belongs_to :office

  scope :by_date, lambda {|date| where(snap_date: date) }
  scope :by_office_id, lambda {|office_id| where(office_id: office_id) }
  scope :by_provisional, lambda {|provisional| where(includes_provisional: provisional) }
  scope :future, lambda { where('snap_date >= ?', Date.today) }

  validates_uniqueness_of :snap_date, scope: [:office_id, :includes_provisional]

  def self.on_date(date, includes_provisional: false, office_id: nil)
    by_date(date).by_office_id(office_id).by_provisional(includes_provisional).first
  end

  def self.on_date!(date, includes_provisional: false, office_id: nil)
    snap_scope = by_date(date).by_provisional(includes_provisional).by_office_id(office_id)
    snap_scope.first_or_create! do |snap|
      snap.calculate
    end
  end

  # TODO: thread with includes_provisional
  def self.for_weekdays_between!(start_date, end_date, office_id=nil)
    week_days_between(start_date, end_date).map { |d| on_date!(d, office_id: office_id) }
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

  def gross_utilization
    self[:gross_utilization] < '0' ? '0' : self[:gross_utilization]
  end

  def utilization_group
    UtilizationGroup.new(people: people, start_date: snap_date, includes_provisional: includes_provisional)
  end
  memoize :utilization_group

  def calculate
    self.staff            = utilization_group.billable_percentages
    self.non_billable     = utilization_group.non_billable_percentages
    self.unassignable     = utilization_group.unassigned_percentages
    self.billing          = utilization_group.billing_percentages
    self.non_billing      = utilization_group.non_billing_percentages
    self.assignable       = utilization_group.assignable_percentages
    self.overallocated    = utilization_group.overallocated_percentages
    self.utilization      = utilization_group.utilization_percentage
    self.gross_utilization = utilization_group.gross_utilization_percentage
  end
end
