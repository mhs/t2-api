namespace :utilization do
  desc "Email a utilization snapshot to important people"
  task "today" => :environment do
    UtilizationMailer.daily(["leadership@neo.com"]).deliver
  end
end
