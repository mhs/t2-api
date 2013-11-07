class AvailabilityCalculator
  attr_reader :person_id, :allocations, :start_date, :end_date

  def initialize(allocations, availability)
    @initial_availability = availability
    @person_id = availability.person_id
    @start_date = availability.start_date
    @end_date = availability.end_date
    @allocations = allocations
  end

  def availabilities
    result = [@initial_availability]
    allocations.sort_by(&:start_date).each do |alloc|
      result = result.flat_map do |av|
        av.remove_range(alloc.start_date, alloc.end_date)
      end
    end
    remove_weekends(result)
  end

  def remove_weekends(avs)
    avs.each do |av|
      av.remove_weekends!
    end.reject { |av| av.empty? }
  end
end
