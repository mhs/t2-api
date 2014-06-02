require 'date_range_helper'

class MonthlySnapshot < ActiveRecord::Base

  include DateRangeHelper

  belongs_to :office

  scope :by_date, lambda {|date| where(snap_date: date.beginning_of_month) }
  scope :by_office_id, lambda {|office_id| office_id ? where(office_id: office_id) : where(false) }
  scope :by_provisional, lambda {|provisional| where(includes_provisional: provisional) }
  scope :future, lambda { where('snap_date >= ?', Date.today - 1.month) }

  validates :snap_date, uniqueness: { scope: [:office_id, :includes_provisional] }

  def self.on_date!(date, includes_provisional: false, office_id: nil)
    rel = where(snap_date: date.beginning_of_month, office_id: office_id, includes_provisional: includes_provisional)
    rel.first_or_create! do |snap|
      snap.calculate
    end
  end

  def self.one_per_month(office_id=nil)
    MonthlySnapshot.order("snap_date ASC").where(office_id: office_id)
  end

  def self.current_month!(includes_provisional: false, office_id: nil)
    on_date!(Date.today, includes_provisional: includes_provisional, office_id: office_id)
  end

  def self.next_month!(includes_provisional: false, office_id: nil)
    on_date!(Date.today.advance(months: 1), includes_provisional: includes_provisional, office_id: office_id)
  end

  def recalculate!
    calculate
    save!
  end

  def calculate
    reset_aggregates
    with_week_days_in(snap_date) do |date|
      Snapshot.on_date!(date, office_id: office_id, includes_provisional: includes_provisional).tap do |snapshot|
        self.billing_days += snapshot.billing.to_fte
        self.assignable_days += snapshot.assignable.to_fte
        self.billable_days += snapshot.billable.to_fte
      end
    end
    self.utilization = assignable_days.zero? ? 0.0 : (billing_days/assignable_days * 100)
    self.gross_utilization = billable_days.zero? ? 0.0 : (billing_days/billable_days * 100)
  end

  def office
    oid = read_attribute(:office_id)
    oid.present? ? Office.find(oid) : Office::SummaryOffice.new
  end

  private

  def reset_aggregates
    self.billing_days    = 0.0
    self.assignable_days = 0.0
  end

end
