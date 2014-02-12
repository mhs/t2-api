class Utilization
  extend Memoist

  attr_accessor :person, :start_date, :end_date

  def initialize(person, start_date=nil, end_date=nil)
    @person     = person
    @start_date = start_date.presence || Date.today
    @end_date   = end_date.presence   || start_date.presence || Date.today
  end

  def billable_percentage
    person.percent_billable.to_f
  end
  memoize :billable_percentage


  def unassigned_percentage
    (billable_percentage * vacation_allocation_percentage) / 100
  end
  memoize :unassigned_percentage

  def billing_percentage
    (billable.sum(:percent_allocated) * (100 - vacation_allocation_percentage)) / 100
  end
  memoize :billing_percentage

  def non_billing_percentage
    slack > 0 ? slack : 0.0
  end
  memoize :non_billing_percentage

  def overallocated_percentage
    slack < 0 ? slack.abs : 0.0
  end
  memoize :overallocated_percentage

  def assignable_percentage
    billable_percentage - unassigned_percentage
  end
  memoize :assignable_percentage

  def to_hash(key=nil)
    if key.present?
      Hash[person, output[key]]
    else
      Hash[person, output]
    end
  end


  private

  def allocations
    person.allocations.within(start_date, end_date)
  end

  def vacation
    allocations.unassignable
  end

  def billable
    allocations.billable.assignable
  end

  def slack
    assignable_percentage - billing_percentage
  end
  memoize :slack

  def vacation_allocation_percentage
    vacation.sum(:percent_allocated).to_f
  end
  memoize :vacation_allocation_percentage

  def output
    { billable_percentage: billable_percentage,
      unassigned_percentage: unassigned_percentage,
      billing_percentage: billing_percentage,
      non_billing_percentage: non_billing_percentage,
      overallocated_percentage: overallocated_percentage,
      assignable_percentage: assignable_percentage,
      start_date: start_date,
      end_date: end_date }
  end
end
