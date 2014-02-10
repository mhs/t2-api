require 'utilization_helper'

# TODO: half-days are not accounted for
class MonthlySnapshot < ActiveRecord::Base

  include UtilizationHelper

  belongs_to :office

  scope :by_date, lambda {|date| where(snap_date: date.beginning_of_month) }
  scope :by_office_id, lambda {|office_id| office_id ? where(office_id: office_id) : where(false) }

  validates :snap_date, uniqueness: { scope: :office }

  def self.on_date!(date, office_id=nil)
    where(snap_date: date.beginning_of_month, office_id: office_id).first_or_initialize.tap do |snap|
      snap.calculate
      snap.save!
    end
  end

  def self.one_per_month(office_id=nil)
    MonthlySnapshot.order("snap_date ASC").where(office_id: office_id)
  end

  def self.today!(office_id=nil)
    on_date!(Date.today, office_id)
  end

  def self.next_month!(office_id=nil)
    on_date!(Date.today.advance(months: 1), office_id)
  end

  def calculate
    with_week_days_in(snap_date) do |date|
      Snapshot.on_date!(date, office_id).tap do |snapshot|
        self.billing_days += snapshot.billing_weights.total / 100.0
        self.assignable_days += snapshot.assignable_weights.total / 100.0
      end
    end
  end

end
