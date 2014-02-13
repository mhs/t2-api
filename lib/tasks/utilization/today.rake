require File.expand_path(File.dirname(__FILE__) + '/report_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../date_range_helper')

namespace :utilization do
  desc "Spit out a report on utilization for Daniel"
  task "today" => :environment do
    include DateRangeHelper

    # global utilization
    today_snapshot = Snapshot.today!
    ReportTemplate.new('views/global_utilization_template.erb').render([today_snapshot])

    offices = Office.reporting

    # per office utilization
    snapshots = offices.map { |office| Snapshot.on_date!(Date.today, office) }
    ReportTemplate.new('views/office_utilization_template.erb').render(snapshots)

    # projected utilization
    projection_snapshots = []
    with_week_days 21 do |date|
      projection_snapshots << Snapshot.on_date!(date)
    end
    ReportTemplate.new('views/projected_utilization_template.erb').render(projection_snapshots)

    # current monthly utilization by office
    current_summary_snapshot  = MonthlySnapshot.today!
    current_monthly_snapshots = offices.map { |office| MonthlySnapshot.today!(office) }.unshift(current_summary_snapshot)
    ReportTemplate.new('views/monthly_utilization_template.erb').render(current_monthly_snapshots)

    # future month utilization by office
    future_summary_snapshot  = MonthlySnapshot.next_month!
    future_monthly_snapshots = offices.map { |office| MonthlySnapshot.next_month!(office) }.unshift(future_summary_snapshot)
    ReportTemplate.new('views/monthly_utilization_template.erb').render(future_monthly_snapshots)

    # people list
    ReportTemplate.new('views/utilization_body_template.erb').render([today_snapshot])
  end
end
