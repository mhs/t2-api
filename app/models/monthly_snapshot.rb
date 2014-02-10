require 'utilization_helper'

class MonthlySnapshot < ActiveRecord::Base
  # NOTE: snap_date is the date of the first day of the month this snapshot applies to
  # TODO: half-days are not accounted for

  include UtilizationHelper

  belongs_to :office

  scope :by_date, lambda {|date| where(snap_date: date.beginning_of_month) }
  scope :by_office_id, lambda {|office_id| office_id ? where(office_id: office_id) : where(false) }

  validates_uniqueness_of :snap_date, scope: :office_id

  def self.on_date!(date, office_id=nil)
    date = date.beginning_of_month
    where(snap_date: date, office_id: office_id).first_or_initialize.tap do |snap|
      snap.calculate
      snap.save!
    end
  end

  def self.one_per_month
    snaps = {}
    MonthlySnapshot.order("snap_date ASC").where(office_id: nil).each do |snap|
      snaps[snap.snap_date] = snap
    end
    snaps.values
  end


  def self.today!(office_id=nil)
    on_date!(Date.today, office_id)
  end

  def self.next_month!(office_id=nil)
    on_date!(Date.today.advance(months: 1), office_id)
  end

  def calculate
    # collect all the daily snapshots needed and tabluate
    self.assignable_days = 0
    self.billing_days = 0
    with_week_days_in(snap_date) do |date|
      snapshot = Snapshot.on_date!(date, office_id).tap do |s|
        s.calculate
      end
      self.billing_days += snapshot.billing_weights.total / 100.0
      self.assignable_days += snapshot.assignable_weights.total / 100.0
    end
  end

end
