class Project < ActiveRecord::Base

  DEFAULT_RATES = {
    'Developer'       => 5400,
    'Designer'        => 5400,
    'Product Manager' => 5400,
    'Principal'       => 5400,
  }

  include HasManyCurrent

  attr_accessible :name, :notes, :billable, :binding,
    :vacation, :start_date, :end_date, :office_ids, :rates, :investment_fridays,
    :selling_office_id, :num_weeks_per_invoice, :typical_counts, :typical_allocation_percentages

  belongs_to :selling_office, class_name: "Office"
  has_many :project_offices
  has_many :offices, through: :project_offices
  has_many :revenue_items, inverse_of: :project
  has_many_current :allocations
  has_many_current :people, -> { uniq }, through: :allocations

  acts_as_paranoid

  validates :name, presence: true, uniqueness: true
  validates :office_ids, presence: true

  after_initialize :set_default_rates

  scope :assignable, -> { where(vacation: true) }
  scope :archived, lambda { |bool| bool ? only_archived : only_active }
  scope :active_within, lambda { |start_date, end_date|
    where("start_date IS NULL OR start_date <= ?", end_date)
    .where("end_date IS NULL OR end_date >= ?", start_date)
  }

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

  def self.only_archived
    where('end_date IS NULL OR end_date < ?', Date.today)
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

  def set_default_rates
    DEFAULT_RATES.each do |role, rate|
      self.rates[role] = rate if self.rates[role].blank?
    end
  end
end
