require 'csv'

class Reports::Revenue
  extend Memoist

  PAST_MONTHS = 6.months
  FUTURE_MONTHS = 36.months

  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date || Date.today.beginning_of_month
    @end_date = end_date || (@start_date + FUTURE_MONTHS).end_of_month

    @start_date = @start_date - PAST_MONTHS
    @projects_hash = Project.within_date_range(start_date, end_date) { Project.all.to_a }.index_by(&:id)
    @offices_hash = Office.all.to_a.index_by(&:id)
  end

  def self.column_names
    [ 'Month', 'Project', 'Office', 'Role', 'Booked', 'Projected',
      '30% Speculative', '60% Speculative', '90% Speculative', 'Total Speculative' ]
  end

  def filename
    "revenue_#{@start_date}-#{@end_date}_on_#{Time.zone.now.to_date}.csv"
  end

  def rows

    named_revenue.to_a.map(&:flatten)
  end

  def to_csv_string
    CSV.generate do |csv|
      csv << self.class.column_names
      rows.each do |row|
        csv << row
      end
    end
  end

  private

  def named_revenue
    combined_revenue.transform_keys do |month, project_id, office_id, role|
      [month, @projects_hash[project_id].name, @offices_hash[office_id].name,  role]
    end.sort
  end

  def combined_revenue
    all_keys = (projected_revenues.keys + booked_revenues.keys).uniq
    all_keys.each_with_object({}) do |key, result|
      booked = booked_revenues.fetch(key, 0.0)
      projected = projected_revenues.fetch(key, 0.0)

      speculative_revenue_30 = speculative_revenues('30% Likely').fetch(key, 0.0)
      speculative_revenue_60 = speculative_revenues('60% Likely').fetch(key, 0.0)
      speculative_revenue_90 = speculative_revenues('90% Likely').fetch(key, 0.0)
      speculative_revenue_total = speculative_revenues.fetch(key, 0.0)

      result[key] = [booked, projected, speculative_revenue_30, speculative_revenue_60, speculative_revenue_90, speculative_revenue_total]
    end.select { |key, (v1, v2)| v1 > 0 || v2 > 0 }
  end
  memoize :combined_revenue

  def projected_revenues
    grouped_revenue.sum(:amount)
  end
  memoize :projected_revenues

  def booked_revenues
    grouped_revenue.booked.sum(:amount)
  end
  memoize :booked_revenues

  def speculative_revenues(likelihood= nil)
    grouped_revenue.speculative(likelihood).sum(:amount)
  end

  def grouped_revenue
    proxy = RevenueItem.group("to_char(day, 'YYYY-MM-01')", :project_id, :office_id, :role)
    proxy.between(start_date, end_date)
  end

end
