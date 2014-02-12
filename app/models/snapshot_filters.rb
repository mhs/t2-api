module SnapshotFilters
  def pure_overhead
    staff.select do |person, billable_percent|
      billable_percent == 0
    end
  end

  def overhead
    staff.select do |person, billable_percent|
      billable_percent != 100
    end
  end

  def billable
    staff.select do |person, billable_percent|
      billable_percent != 0
    end
  end

  def pure_billable
    staff.select do |person, billable_percent|
      billable_percent == 100
    end
  end

  def partially_billable
    staff.select do |person, billable_percent|
      billable_percent.between?(1, 99)
    end
  end
  alias_method :partially_overhead, :partially_billable
end
