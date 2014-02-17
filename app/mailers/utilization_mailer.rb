require 'date_range_helper'

class UtilizationMailer < ActionMailer::Base
  layout 'mailer'
  include DateRangeHelper

  def daily
    recipients = "aaron@neo.com"
    @report = UtilizationDailyReport.new
    mail to: recipients, subject: "Daily Utilization", from: "T2 Utilization"
  end
end
