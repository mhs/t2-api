class MonthlyUtilizationTemplate
  def initialize(summary_snapshot, monthly_snapshots, title="Monthly Utilization Report")
    @summary_snapshot = summary_snapshot
    @monthly_snapshots = monthly_snapshots.sort_by {|s| s.office.name}
    @report_title =  "#{title} - #{@summary_snapshot.snap_date.strftime("%B %Y")}"
  end

  def format_row(title, snapshot)
    fraction = "#{snapshot.billing_days.to_s.ljust(5, ' ')} / #{snapshot.assignable_days}".ljust(14, ' ')
    ratio = ((100.0 * snapshot.billing_days) / snapshot.assignable_days) rescue 0.0
    "#{title.ljust(20, ' ')} - #{fraction} = #{"%.1f" % ratio}%\n"
  end

  def divider
    '-'*(@report_title.length)
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/monthly_utilization_template.erb')
erb = ERB.new(File.read(filename),0,'>')
erb.def_method(MonthlyUtilizationTemplate, 'render()', filename)
