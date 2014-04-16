class Overlap
  extend Memoist

  attr_reader :person, :start_date, :end_date, :allocations, :percent_allocated

  def initialize(person:, start_date:, end_date:, allocations: [], percent_allocated: 0)
    @person = person
    @start_date = start_date
    @end_date = end_date
    # raise ArgumentError, "you done goofed" if end_date < start_date
    binding.pry if end_date < start_date
    @allocations = allocations
    @percent_allocated = percent_allocated
  end

  def id
    "#{person.id}-#{start_date}-#{end_date}-#{allocations.map(&:id).join('-')}-#{percent_allocated}"
  end
  memoize :id

  def ==(other)
    self.person == other.person &&
      self.start_date === other.start_date &&
      self.end_date === other.end_date &&
      self.percent_allocated == other.percent_allocated
      self.allocations == other.allocations
  end

  def overlaps_for(alloc)
    # NOTE: this avoids the multi-way branch by always assuming that
    #       alloc is in the middle. If that isn't the case, some of the
    #       calls to 'similar' will return nil and be compacted away.
    #
    [
      similar(end_date: alloc.start_date - 1.day),
      similar(start_date: alloc.start_date,
              end_date: alloc.end_date,
              percent_allocated: percent_allocated + alloc.percent_allocated,
              allocations: allocations + [alloc]),
      similar(start_date: alloc.end_date + 1.day)
    ].compact
  end

  def conflicting?
    return false unless allocations.size > 1
    percent_allocated > person.percent_billable ||
      allocations.any?(&:vacation?)
  end

  def available?
    percent_allocated < person.percent_billable
  end

  def to_availability
    Availability.new(person_id: person.id,
                     start_date: start_date,
                     end_date: end_date,
                     percent_allocated: person.percent_billable - percent_allocated)
  end

  def active_model_serializer
    ConflictSerializer
  end

  alias read_attribute_for_serialization send

  private

  def attributes
    {
      person: person,
      start_date: start_date,
      end_date: end_date,
      allocations: allocations,
      percent_allocated: percent_allocated
    }
  end

  def similar(**args)
    # NOTE: this is tricky.
    #       * If overlaps_for generates an invalid region
    #         (start_date > end_date) then omit it.
    #       * If overlaps_for generates a region outside our
    #         bounds, limit the endpoints
    #
    new_attributes = attributes.merge(args)
    new_attributes[:start_date] = [new_attributes[:start_date], start_date].max
    new_attributes[:end_date] = [new_attributes[:end_date], end_date].min
    return if new_attributes[:start_date] > new_attributes[:end_date]
    self.class.new(**new_attributes)
  end

end
