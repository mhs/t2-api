class UtilizationMailer < ActionMailer::Base
  layout 'mailer'

  def daily(recipients="bot@neo.com")
    @report = UtilizationDailyReport.new
    mail to: recipients, from: from("daily+utilization"), subject: subject("Daily Utilization For #{Date.today.to_s(:long)}")
  end


  private

  def subject(s)
    return s if Rails.env.production?
    "[#{Rails.env}] #{s}"
  end

  def from(f)
    "T2 Utilization <bot+#{f}@neo.com>"
  end
end
