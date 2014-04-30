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

  NON_BILLING_ROLES = [
    'Apprentice',
    'Business Development',
    'General & Administrative',
    'Support Staff'
  ]

  ALIASED_ROLES = {
    'Managing Director' => 'Principal'
  }

  def rate_for(role)
    return 0.0 if NON_BILLING_ROLES.include?(role)

    rate = rates[role] || rates[ALIASED_ROLES[role]]
    rate.to_f / (investment_fridays? ? 4 : 5)
  end

  protected

  def update_provisional_allocations
    # if we have changed from provisional to not, update the
    # allocations to match
    return unless !provisional? && provisional_was
    allocations.update_all(provisional: false)
  end
end
