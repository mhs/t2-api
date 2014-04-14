class OverlapCalculator

  attr_reader :allocations

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

end
