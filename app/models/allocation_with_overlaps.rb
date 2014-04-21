class AllocationWithOverlaps < DelegateClass(Allocation)
  attr_reader :person

  def initialize(allocation, window_start:, window_end:)
    super(allocation)
    @window_start = window_start
    @window_end = window_end
    Allocation.within_date_range(window_start, window_end) do
      # only want @person to have allocations in the date range
      @person = Person.includes(:allocations).find(allocation.person_id)
    end
    @conflicts = @person.conflicts_for(window_start, window_end)
    @allocations_hash = @person.allocations.within(window_start, window_end).index_by(&:id)
    @conflicts.each do |conflict|
      conflict.allocations.each do |alloc|
        __setobj__(@allocations_hash[alloc.id]) if alloc.id == allocation.id # no identity map :(
        @allocations_hash[alloc.id].conflicts << conflict
      end
    end
  end

  def allocations
    [self] + (@allocations_hash.values - [__getobj__])
  end

  def active_model_serializer
    AllocationWithOverlapsSerializer
  end

  alias read_attribute_for_serialization send
end
