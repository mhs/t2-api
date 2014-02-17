require 'date_range_helper'

class UtilizationMailer < ActionMailer::Base
  layout 'mailer'
  include DateRangeHelper

  def daily
    recipients = "aaron@neo.com"
    offices = Office.reporting
    @global = [Snapshot.today!]
    @projected = []
    with_week_days 21 do |date|
      @projected << Snapshot.on_date!(date)
    end

    @current_month = [MonthlySnapshot.today!]
    @current_month += offices.map { |office| MonthlySnapshot.today!(office) }

    @future_month = [MonthlySnapshot.next_month!]
    @future_month += offices.map { |office| MonthlySnapshot.next_month!(office) }

    mail to: recipients, subject: "Daily Utilization", from: "T2 Utilization"
  end
end
