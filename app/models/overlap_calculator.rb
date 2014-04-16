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

  def conflicts
    overlaps.select(&:conflicting?)
  end

end
