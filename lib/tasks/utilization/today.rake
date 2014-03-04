namespace :utilization do
  include DateRangeHelper

  desc "Email a utilization snapshot to important people"
  task "today" => :environment do
    send_daily_email
  end

  def send_daily_email
    if weekend?
      puts "No weekend delivery"
      return
    else
      UtilizationMailer.daily(["leadership@neo.com"]).deliver
    end
  end
end
