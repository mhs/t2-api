class UtilizationDailyReport
  include DateRangeHelper
  extend Memoist

  def offices
    @offices ||= Office.reporting
  end

  def global
    [Snapshot.today!]
  end
  memoize :global

  def projected(weekdays=21)
    projected = []
    with_week_days(weekdays) do |date|
      projected << Snapshot.on_date!(date)
    end
    projected
  end

  def current_month
    [MonthlySnapshot.today!] + offices.map { |office| MonthlySnapshot.today!(office) }
  end

  def next_month
    [MonthlySnapshot.next_month!] + offices.map { |office| MonthlySnapshot.next_month!(office) }
  end

end
