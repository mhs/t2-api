require File.expand_path(File.dirname(__FILE__) + '/monthly_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/report_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../date_range_helper')

namespace :utilization do
  desc "Spit out a report on utilization for Daniel"
  task "today" => :environment do

    include DateRangeHelper

    # global utilization
    today_snapshot = Snapshot.today!
    puts_if_no_test ReportTemplate.new('views/global_utilization_template.erb').render([today_snapshot])

    offices = Office.reporting

    # per office utilization
    snapshots = offices.map { |office| Snapshot.on_date!(Date.today, office) }
    puts_if_no_test ReportTemplate.new('views/office_utilization_template.erb').render(snapshots)

    # projected utilization
    projection_snapshots = []
    with_week_days 21 do |date|
      projection_snapshots << Snapshot.on_date!(date)
    end
    puts_if_no_test ReportTemplate.new('views/projected_utilization_template.erb').render(projection_snapshots)

    # current monthly utilization
    summary_snapshot = MonthlySnapshot.today!
    monthly_snapshots = offices.map { |office| MonthlySnapshot.today!(office) }
    puts_if_no_test MonthlyUtilizationTemplate.new(summary_snapshot, monthly_snapshots).render()

    # projected monthly utilization
    summary_snapshot = MonthlySnapshot.next_month!
    monthly_snapshots = offices.map { |office| MonthlySnapshot.next_month!(office) }
    t = "Projected Monthly Utilization Report"
    puts_if_no_test MonthlyUtilizationTemplate.new(summary_snapshot, monthly_snapshots, t).render()

    # people list
    puts_if_no_test ReportTemplate.new('views/utilization_body_template.erb').render([today_snapshot])
  end
end
