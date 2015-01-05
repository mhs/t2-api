class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :binding,
                  :person, :person_id, :project, :project_id, :percent_allocated,
                  :likelihood, :role

  attr_accessor :conflicts # used by the serialization code

  ALL_LIKELIHOODS = ['30% Likely','60% Likely','90% Likely', '100% Booked']
  BOOKED_LIKELIHOODS = ['100% Booked']
  SPECULATIVE_LIKELIHOODS = ALL_LIKELIHOODS - BOOKED_LIKELIHOODS

  belongs_to :person
  belongs_to :project
  has_one :office, through: :person
  belongs_to :creator, class_name: 'User'
  has_many :revenue_items, inverse_of: :allocation

  before_destroy :clean_up_revenue

  validates :project_id, :start_date, :end_date, :likelihood, presence: true
  validates_date :end_date, on_or_after: :start_date
  validate :person_or_role_present
  validates :percent_allocated, inclusion: {in: 0..100, message: "must be between 0 and 100"}

  scope :current, -> { includes(:project).where("projects.deleted_at is NULL").references(:project) }
  def self.between(start_date, end_date)
    where("allocations.start_date >= ?", start_date.to_date)
    .where("allocations.end_date <= ?", end_date.to_date)
  end

  def self.within(start_date, end_date)
    # NOTE: this is subtly different from between, which excludes allocations that
    #       start before start_date or end after end_date.
    where("allocations.start_date <= ? OR allocations.start_date IS NULL", end_date.to_date)
    .where("allocations.end_date >= ? OR allocations.end_date IS NULL", start_date.to_date)
  end

  def self.for_date(d)
    joins(:project)
    .where("projects.id IS NOT NULL")
    .where("allocations.start_date <= ?", d.to_date)
    .where("allocations.end_date >= ?", d.to_date)
  end

  scope :on_date, lambda { |d| for_date(d).current }
  scope :this_year, -> { between(Date.today.beginning_of_year, Date.today.end_of_year).current }
  scope :starting_soon, -> { where("allocations.start_date >= ?", Date.today ).where("allocations.start_date <= ?", 2.days.from_now) }
  scope :assignable, -> { current.includes(:project).where(:projects => { vacation: false }) }
  scope :unassignable, -> { current.includes(:project).where(:projects => { vacation: true }) }
  scope :billable, -> { where(billable: true) }
  scope :provisional, -> { where(provisional: true) }
  scope :bound, -> { where(binding: true) }
  scope :vacation, -> { current.where(:projects => { vacation: true }) }
  scope :by_office, lambda { |office| office ? joins(:office).where("people.office_id" => office.id) : where(false) }
  scope :includes_provisional, lambda { |x| x ? where(nil) : where(provisional: false) }
  scope :speculative, -> { where(likelihood: SPECULATIVE_LIKELIHOODS) }

  scope :billable_and_assignable, -> { billable.assignable }

  delegate :name, to: :project, prefix: true, :allow_nil => true

  def self.overlaps_this_year
    where("(start_date >= ? and start_date <= ?) OR (end_date >= ? and end_date <= ?)",
          Date.today.beginning_of_year,Date.today.end_of_year,
          Date.today.beginning_of_year,Date.today.end_of_year)
  end

  def vacation?
    project.vacation?
  end

  def holiday?
    project.holiday?
  end

  def conflicts
    @conflicts ||= []
  end

  def week_days
    (start_date..end_date).to_a.reject{|d| [6,7].include?(d.cwday)}
  end

  private

  def clean_up_revenue
    # NOTE: This is a bit tricky. This month and future revenue can be destroyed, but
    #       revenue generated before the beginning of this month has been reported and
    #       should not be destroyed.
    #
    revenue_items.this_month_and_on.destroy_all
    revenue_items.before_this_month.update_all(allocation_id: nil)
  end

  def person_or_role_present
    if person.nil? && role.nil?
      errors.add(:person_id, 'Need to select a role or person')
    end
  end

end
