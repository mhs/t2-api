class NotImplementedByParentClass < StandardError; end

class Project < ActiveRecord::Base
  include HasManyCurrent

  TYPES = %w[StandardProject Workshop]

  attr_accessible :name, :notes, :billable, :binding, :provisional,
    :vacation, :start_date, :end_date, :office_ids, :rates, :investment_fridays,
    :typical_allocation_percentages, :typical_counts, :num_weeks_per_invoice,
    :selling_office_id

  belongs_to :selling_office, class_name: "Office"
  has_many :project_offices
  has_many :offices, through: :project_offices
  has_many :revenue_items, inverse_of: :project
  has_many_current :allocations
  has_many_current :people, -> { uniq }, through: :allocations

  acts_as_paranoid

  validates :name, presence: true, uniqueness: true
  validates :office_ids, presence: true
  validates :type, inclusion: TYPES

  after_update :update_provisional_allocations

  scope :assignable, -> { where(vacation: true) }
  scope :archived, lambda { |bool| bool ? only_archived : only_active }

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

  def rate_for(role)
    raise NotImplementedByParentClass
  end

  protected

  def update_provisional_allocations
    # if we have changed from provisional to not, update the
    # allocations to match
    return unless !provisional? && provisional_was
    allocations.update_all(provisional: false)
  end
end
