require File.expand_path(File.dirname(__FILE__) + '/global_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/utilization_body_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/office_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/monthly_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/projected_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../utilization_helper')

namespace :utilization do
  desc "Spit out a report on utilization for Daniel"
  task "today" => :environment do

    include UtilizationHelper

    # Global Utilization
    today_snapshot = Snapshot.today!
    puts_if_no_test GlobalUtilizationTemplate.new(today_snapshot).render()

    offices = Office.reporting

    snapshots = offices.map { |office| Snapshot.on_date!(Date.today, office) }

    puts_if_no_test OfficeUtilizationTemplate.new(snapshots).render()

    # Global 3 weeks utilization forecast
    projection_snapshots = []
    with_week_days 21 do |date|
      projection_snapshots << Snapshot.on_date!(date)
    end

    puts_if_no_test ProjectedUtilizationTemplate.new(projection_snapshots).render()

    # current monthly utilization
    summary_snapshot = MonthlySnapshot.today!
    monthly_snapshots = offices.map { |office| MonthlySnapshot.today!(office) }
    puts_if_no_test MonthlyUtilizationTemplate.new(summary_snapshot, monthly_snapshots).render()

    # projected monthly utilization
    summary_snapshot = MonthlySnapshot.next_month!
    monthly_snapshots = offices.map { |office| MonthlySnapshot.next_month!(office) }
    t = "Projected Monthly Utilization Report"
    puts_if_no_test MonthlyUtilizationTemplate.new(summary_snapshot, monthly_snapshots, t).render()

    # Body that includes actual people list
    puts_if_no_test UtilizationBodyTemplate.new(today_snapshot).render()
  end
end
