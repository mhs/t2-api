class RevenueItem < ActiveRecord::Base

  attr_protected # not creatable from the API

  belongs_to :allocation, inverse_of: :revenue_items
  belongs_to :office, inverse_of: :revenue_items
  belongs_to :person, inverse_of: :revenue_items
  belongs_to :project, inverse_of: :revenue_items

  before_save :compute_amount

  scope :for_project, -> (project) { where(project: project) }

  store_accessor :details, :holiday_in_week, :investment_fridays, :vacation_percentage, :percent_allocated, :base_rate

  def self.create_from_overlaps!(daily_overlaps:[], holiday_in_week: false)
    daily_overlaps.flat_map do |overlap|
      next [] if overlap.has_holiday?
      day = overlap.start_date
      is_friday = day.friday?
      vacation_percentage = overlap.vacation_percentage
      # TODO: what happens with collisions?
      overlap.allocations.map do |allocation|
        for_allocation(allocation,
          day: day,
          vacation_percentage: vacation_percentage,
          holiday_in_week: holiday_in_week
        )
      end
    end
  end

  def self.for_allocation(allocation, day:, vacation_percentage: 0, holiday_in_week: false)
    person = allocation.person
    project = allocation.project
    # TODO: what if one already exists? Need to update it.
    create!({
      :allocation => allocation,
      :office => allocation.office,
      :person => person,
      :project => allocation.project,
      :day => day,
      :role => person.role,
      :base_rate => project.rate_for(person.role),
      :provisional => allocation.provisional,
      :vacation_percentage => vacation_percentage,
      :holiday_in_week => holiday_in_week,
      :investment_fridays => project.investment_fridays?,
      :percent_allocated => allocation.percent_allocated
    })
  end

  # hstore turns values into strings, fix that

  def holiday_in_week
    super == "1" || super == true
  end

  def investment_fridays
    super == "1" || super == true
  end

  def percent_allocated
    super.to_i
  end

  def vacation_percentage
    super.to_i
  end

  def base_rate
    super.to_f
  end

  private

  def compute_amount
    assignable_percentage = (100 - vacation_percentage)/100.0
    amount_billed = rate * (percent_allocated/100.0)

    self.amount = assignable_percentage * amount_billed
  end

  def rate
    really_investment_fridays = day.friday? && !holiday_in_week && investment_fridays
    if really_investment_fridays
      0.0
    else
      base_rate
    end
  end

end
