class Overlap

  attr_reader :person, :start_date, :end_date, :allocations, :percent_allocated

  def initialize(person:, start_date:, end_date:, allocations: [], percent_allocated: 0)
    @person = person
    @start_date = start_date
    @end_date = end_date
    raise ArgumentError, "you done goofed" if end_date < start_date
    @allocations = allocations
    @percent_allocated = percent_allocated
  end

  def ==(other)
    self.person == other.person &&
      self.start_date === other.start_date &&
      self.end_date === other.end_date &&
      self.percent_allocated == other.percent_allocated
      self.allocations == other.allocations
  end

  def similar(**args)
    self.class.new(**attributes.merge(args))
  end

  def overlaps_for(alloc)
    return [self] if alloc.end_date < start_date || alloc.start_date > end_date

    if alloc.start_date <= start_date && alloc.end_date >= end_date
      #  self:   |----|
      #  alloc: |------|
      [
        similar(percent_allocated: percent_allocated + alloc.percent_allocated,
                allocations: allocations + [alloc])
      ]
    elsif alloc.start_date <= start_date
      #  self:  |----|
      # alloc: |----|
      [
        similar(end_date: alloc.end_date,
                percent_allocated: percent_allocated + alloc.percent_allocated,
                allocations: allocations + [alloc]),
        similar(start_date: alloc.end_date + 1.day)
      ]
    elsif alloc.end_date >= end_date
      #  self: |----|
      # alloc:  |----|
      [
        similar(end_date: alloc.start_date - 1.day),
        similar(start_date: alloc.start_date,
                percent_allocated: percent_allocated + alloc.percent_allocated,
                allocations: allocations + [alloc]),
      ]
    else
      #  self: |-------|
      # alloc:   |---|
      # we know the following:
      # alloc.start_date > start_date (from the tests above)
      # alloc.end_date < end_date (from the tests above)
      # alloc.end_date >= start_date (from the initial guard)
      # alloc.start_date <= end_date (from the initial guard
      # so:
      # start_date < alloc.start_date <= alloc.end_date < end_date
      [
        similar(end_date: alloc.start_date - 1.day),
        similar(start_date: alloc.start_date,
                end_date: alloc.end_date,
                percent_allocated: percent_allocated + alloc.percent_allocated,
                allocations: allocations + [alloc]),
        similar(start_date: alloc.end_date + 1.day)
      ]
    end
  end

  protected

  def attributes
    {
      person: person,
      start_date: start_date,
      end_date: end_date,
      allocations: allocations,
      percent_allocated: percent_allocated
    }
  end
end
