class OverlapCalculator
  extend Memoist

  attr_reader :allocations

  # NOTE: non-binding (non-exclusive) allocations never conflict
  #       do not pass them to this method
  #
  def initialize(initial_overlap, allocations)
    @initial_overlap = initial_overlap
    @allocations = allocations
  end

  def overlaps
    result = [@initial_overlap]
    allocations.sort_by(&:start_date).each do |alloc|
      result = result.flat_map do |overlap|
        overlap.overlaps_for(alloc)
      end
    end
    result
  end
  memoize :overlaps

  def overlaps_by_day
    overlaps.flat_map { |o| o.split_by_day }
  end

  def conflicts
    overlaps.select(&:conflicting?)
  end

  def availabilities
    overlaps.select(&:available?).map(&:to_availability)
  end

end
