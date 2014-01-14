class WeightCalculator
  extend Memoist

  attr_reader :date, :office

  def initialize(date, office=nil)
    @date = date
    @office = office
  end

  def staff
    result = {}
    allocations.each do |person|
      result[person] = person.percent_billable
    end
    WeightedSet.new(result)
  end
  memoize :staff

  def vacations
    allocation_sum(allocations.unassignable)
  end
  memoize :vacations

  def unassignable
    # Unsellable = ALWAYS overhead (e.g. the CEO)
    # Unassignable = Usually available to be assigned, but out on vacation or something like that
    result = {}
    vacations.each_pair do |person, vacation_percent|
      result[person] = (person.percent_billable * vacation_percent) / 100
    end
    WeightedSet.new(result).compact
  end
  memoize :unassignable

  def billing
    billing_percents = allocation_sum(allocations.billable_and_assignable)
    result = {}
    billing_percents.each_pair do |person, billing_percent|
      result[person] = (billing_percent * (100 - vacations[person]))/100
    end
    WeightedSet.new(result).compact
  end
  memoize :billing

  def allocation_sum
    sums = Hash.new(0)
    allocations.each_with_object(sums) do |allocation, s|
      s[allocation.person] += allocation.percent_allocated
    end
    sums
  end

  def allocations
    Allocation.by_office(office).on_date(date).includes(:person)
  end
end
