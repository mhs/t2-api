class Utilization
  extend Memoist

  attr_accessor :person, :start_date, :end_date

  def initialize(person, start_date=nil, end_date=nil)
    @person     = person
    @start_date = start_date.presence || Date.today
    @end_date   = end_date.presence   || start_date.presence || Date.today
  end

  def billable_percentage
    person.percent_billable
  end

  def unassigned_percentage
    (billable_percentage * vacation.sum(:percent_allocated)).to_f / 100
  end
  memoize :unassigned_percentage

  def billing_percentage
    (billable.sum(:percent_allocated) * (100 - vacation.sum(:percent_allocated))) / 100
  end
  memoize :billing_percentage

  def available_percentage
    100 - unassigned_percentage - billing_percentage
  end

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

  def output
    { billable_percentage: billable_percentage,
      unassigned_percentage: unassigned_percentage,
      billing_percentage: billing_percentage,
      available_percentage: available_percentage,
      start_date: start_date,
      end_date: end_date }
  end
end
