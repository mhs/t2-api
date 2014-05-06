class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :binding, :provisional, :person, :person_id, :project, :project_id, :percent_allocated

  attr_accessor :conflicts # used by the serialization code

  belongs_to :person
  belongs_to :project
  has_one :office, through: :person
  belongs_to :creator, class_name: 'User'

  validates :person_id, :project_id, :start_date, :end_date, presence: true
  validates_date :end_date, on_or_after: :start_date

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

  scope :billable_and_assignable, -> { billable.assignable }

  delegate :name, to: :project, prefix: true, :allow_nil => true

  def vacation?
    project.vacation?
  end

  def conflicts
    @conflicts ||= []
  end
end
