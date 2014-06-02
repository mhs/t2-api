class Project < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :billable, :binding, :provisional, :slug,
    :client_principal_id, :vacation, :start_date, :end_date, :office_ids,
    :rates, :investment_fridays, :typical_allocation_percentages, :typical_counts,
    :num_weeks_per_invoice, :selling_office_id

  has_one :client_principal, class_name: "Person"
  belongs_to :selling_office, class_name: "Office"
  has_many :project_offices
  has_many :offices, through: :project_offices
  has_many :revenue_items, inverse_of: :project
  has_many_current :allocations
  has_many_current :people, -> { uniq }, through: :allocations

  acts_as_paranoid

  validates :name, presence: true, uniqueness: true
  validates :office_ids, presence: true

  after_update :update_provisional_allocations

  scope :assignable, -> { where(vacation: true) }

  def self.holiday_project
    where(holiday: true).first
  end

  def self.search(query)
    return where(false) if query.blank?
    where('projects.name ILIKE ?', "%#{query}%")
  end

  def self.for_office_id(office_id)
    return where(false) if office_id.blank?
    joins(:offices).where(offices: { id: office_id })
  end

  def self.base_order
    order(:billable => :desc).where(holiday: false, vacation: false)
  end

  def self.only_active
    where('end_date IS NULL OR end_date >= ?', Date.today)
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
