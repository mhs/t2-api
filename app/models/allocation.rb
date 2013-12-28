class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :binding, :slot, :slot_id, :person, :person_id, :project, :project_id

  TIME_WINDOW = 20 # weeks

  belongs_to :slot
  belongs_to :person
  belongs_to :project
  has_one :office, through: :person

  validates :person_id, :project_id, :start_date, :end_date, presence: true
  validates_date :end_date, on_or_after: :start_date

  validate :does_not_exceed_project_allowance

  scope :current, -> { includes(:project).where("projects.deleted_at is NULL").references(:project) }
  def self.between(start_date, end_date)
    where("allocations.start_date >= ?", start_date.to_date)
    .where("allocations.end_date <= ?", end_date.to_date)
  end

  def self.within(start_date, end_date)
    # NOTE: this is subtly different from between, which excludes allocations that
    #       start before start_date or end after end_date.
    where("allocations.start_date <= ?", end_date.to_date)
    .where("allocations.end_date >= ?", start_date.to_date)
  end

  def self.for_date(d)
    joins(:project)
    .where("projects.id IS NOT NULL")
    .where("allocations.start_date <= ?", d.to_date)
    .where("allocations.end_date >= ?", d.to_date)
  end

  scope :on_date, lambda { |d| for_date(d).current }
  scope :this_year, lambda { between(Date.today.beginning_of_year, Date.today.end_of_year).current }
  scope :assignable, -> { current.includes(:project).where(:projects => { vacation: false }) }
  scope :unassignable, -> { current.includes(:project).where(:projects => { vacation: true }) }
  scope :billable, -> { where(billable: true) }
  scope :unbillable, -> { where(billable: false) }
  scope :bound, -> { where(binding: true) }
  scope :billable_projects, -> { current.includes(:project).where(:projects => { billable: true }) }
  scope :with_start_date, lambda { |d| where("allocations.start_date <= ?", d.to_date + TIME_WINDOW.weeks).where("allocations.end_date >= ?", d.to_date).current }
  scope :vacation, -> { current.where(:projects => { vacation: true }) }
  scope :for_person, lambda { |person_or_id| joins(:person).where("people.id = ?", person_or_id.is_a?(Fixnum) ? person_or_id : person_or_id.id) }
  scope :by_office, lambda { |office| office ? joins(:office).where("people.office_id" => office.id) : where(false) }

  scope :unbillable_for_billable_projects, -> { unbillable.bound.billable_projects }
  scope :billable_and_assignable, -> { billable.assignable }
  scope :by_office_and_date, ->(office, date) { by_office(office).on_date(date) }

  delegate :name, to: :project, prefix: true, :allow_nil => true

  def duration_in_hours
    duration_in_days * 8
  end

  def vacation?
    project.vacation?
  end

  private

  def does_not_exceed_project_allowance
    return unless person && project
    errors.add(:base, "can't exceed project allowance") if AllowanceCalculator.new(person, project).exceeds_allowance? duration_in_hours
  end

  def duration_in_days
    weekdays.count
  end

  def weekdays
    (start_date && end_date) ?
      (start_date.to_date..end_date.to_date).select {|day| is_weekday? day } :
      []
  end

  def is_weekday? day
    (1..5).cover? day.wday
  end

end
