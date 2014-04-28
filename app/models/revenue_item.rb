class RevenueItem < ActiveRecord::Base

  belongs_to :allocation, inverse_of: :revenue_items
  belongs_to :office, inverse_of: :revenue_items
  belongs_to :person, inverse_of: :revenue_items
  belongs_to :project, inverse_of: :revenue_items

  before_save :compute_amount

  scope :for_project, -> (project) { where(project: project) }

  def self.create_from_overlaps!(daily_overlaps:[], holiday_in_week: false)
    daily_overlaps.flat_map do |overlap|
      next [] if overlap.has_holiday?
      day = overlap.start_date
      is_friday = day.friday?
      vacation_percentage = overlap.vacation_percentage
      # TODO: what happens with collisions?
      overlap.allocations.map do |allocation|
        person = allocation.person
        self.class.create!({
          :allocation => allocation,
          :office => allocation.office,
          :person => person,
          :project => allocation.project,
          :day => day,
          :role => person.role,
          :provisional => allocation.provisional,
          :vacation_percentage => vacation_percentage,
          :holiday_in_week => holiday_in_week
        })
      end
    end
  end

  private

  def compute_amount
    assignable_percentage = (100 - vacation_percentage)/100.0
    amount_billed = rate * (allocation.percent_allocated/100.0)

    self.amount = assignable_percentage * amount_billed
  end

  def rate
    really_investment_fridays = day.friday? && !holiday_in_week && project.investment_fridays?
    if really_investment_fridays
      0.0
    else
      project.rate_for(role)
    end
  end

end
