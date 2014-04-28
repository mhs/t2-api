class Project < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :billable, :binding, :provisional, :slug, :client_principal_id, :vacation, :start_date, :end_date, :office_ids

  has_one :client_principal, class_name: "Person"
  has_many :project_offices
  has_many :offices, through: :project_offices
  has_many :revenue_items, inverse_of: :project
  has_many_current :allocations
  has_many_current :people, through: :allocations

  acts_as_paranoid

  after_update :update_provisional_allocations

  scope :assignable, -> { where(vacation: true) }

  def self.holiday_project
    where(holiday: true).first
  end

  # TODO: make this configurable per-project
  # this is per-day internally, but may need to be cooked on input
  def rate_for(role)
    {
      'Apprentice' => 0.0,
      'Business Development' => 0.0,
      'Designer' => 7000.0,
      'Developer' => 7000.0,
      'General & Administrative' => 0.0,
      'Managing Director' => 14000.0,
      'Principal' => 14000.0,
      'Product Manager' => 10000.0,
      'Support Staff' => 0.0
    }[role]
  end

  # TODO: do we need to filter by office? by role?
  # TODO: Refactor this into better objs
  def revenue_for(start_date:, end_date:, includes_provisional: false)
    # TODO: filter these by which allocations belong to us
    Allocation.includes_provisional(includes_provisional).within_date_range(start_date, end_date) do
      # TODO: uniq should really be in the association
      people.uniq.map do |person|
        rate = rate_for(person.role)
        overlaps_by_week = person.overlap_calculator_for(start_date, end_date).overlaps_by_day.group_by { |o| o.start_date.cweek }
        overlaps_by_week.map do |week, overlaps|
          holiday_in_week = overlaps.any?(&:has_holiday?)
          really_investment_fridays = investment_fridays? && !holiday_in_week
          overlaps.map do |overlap|
            if !overlap.allocation_for(self)
              # not ours
              0.0
            elsif overlap.vacation? || overlap.has_holiday?
              # TODO: handle partial-day vacation
              0.0
            elsif overlap.start_date.friday? && really_investment_fridays
              0.0
            else
              # TODO: handle people who have non-billing allocations (needed?)
              allocation = overlap.allocation_for(self)
              vacation_percentage = overlap.vacation_percentage
              (100 - vacation_percentage) * (rate * allocation.percent_allocated)/100
            end
          end.sum
        end.sum
      end.sum
    end
  end

  protected

  def update_provisional_allocations
    # if we have changed from provisional to not, update the
    # allocations to match
    return unless !provisional? && provisional_was
    allocations.update_all(provisional: false)
  end
end
