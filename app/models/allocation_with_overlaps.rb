class AllocationWithOverlaps < DelegateClass(Allocation)
  attr_reader :conflicts, :person

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
        @allocations_hash[alloc.id].conflicts << conflict
      end
    end
  end

  def allocations
    [__getobj__] + (@allocations_hash.values - [__getobj__])
  end

  def active_model_serializer
    AllocationWithOverlapsSerializer
  end
end
