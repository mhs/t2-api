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
      projected << [Snapshot.on_date!(date), Snapshot.on_date!(date, includes_speculative: true)]
    end
    projected
  end

  def today
    offices.map { |office| Snapshot.on_date!(Date.today, office_id: office.id) }
  end

  def current_month
    overall = [[MonthlySnapshot.current_month!, MonthlySnapshot.current_month!(includes_speculative: true)]]
    per_office = offices.map do |office|
      [MonthlySnapshot.current_month!(office_id: office.id),
       MonthlySnapshot.current_month!(office_id: office.id, includes_speculative: true)]
    end
    overall + per_office
  end

  def next_month
    overall = [[MonthlySnapshot.next_month!, MonthlySnapshot.next_month!(includes_speculative: true)]]
    per_office = offices.map do |office|
      [MonthlySnapshot.next_month!(office_id: office.id),
       MonthlySnapshot.next_month!(office_id: office.id, includes_speculative: true)]
    end
    overall + per_office
  end

end
