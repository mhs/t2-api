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
    %w[Month Project Office Role Booked Projected]
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
      result[key] = [booked, projected]
    end.select { |key, (v1, v2)| v1 > 0 || v2 > 0 }
  end
  memoize :combined_revenue

  def projected_revenues
    grouped_revenue.sum(:amount)
  end
  memoize :projected_revenues

  def booked_revenues
    grouped_revenue.where(provisional: false).sum(:amount)
  end
  memoize :booked_revenues

  def grouped_revenue
    proxy = RevenueItem.group("to_char(day, 'YYYY-MM-01')", :project_id, :office_id, :role)
    proxy.between(start_date, end_date)
  end

end
