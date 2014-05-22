class RevenueCalculator
  extend Memoist

  attr_reader :start_date, :end_date, :person

  def initialize(start_date:, end_date:, person:)
    @start_date = start_date
    @end_date = end_date
    @person = person
  end

  def revenue_items
    overlaps.flat_map do |_, week_of_overlaps|
      holiday_in_week = week_of_overlaps.any?(&:has_holiday?)
      week_of_overlaps.flat_map do |overlap|
        next [] if overlap.has_holiday?
        day = overlap.start_date
        vacation_percentage = overlap.vacation_percentage
        overlap.allocations.map do |allocation|
          RevenueItem.for_allocation!(allocation,
            day: day,
            vacation_percentage: vacation_percentage,
            holiday_in_week: holiday_in_week
          )
        end
      end
    end
  end

  private

  def overlaps
    calculator = person.overlap_calculator_for(start_date, end_date)
    calculator.overlaps_by_day.group_by { |o| o.start_date.cweek }
  end
  memoize :overlaps

end

