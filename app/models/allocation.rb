class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :binding, :provisional, :person, :person_id, :project, :project_id, :percent_allocated

  attr_accessor :conflicts # used by the serialization code
  TIME_WINDOW = 20 # weeks

  belongs_to :person
  belongs_to :project
  has_one :office, through: :person
  has_many :revenue_items, inverse_of: :allocation

  before_destroy :clean_up_revenue

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
  scope :assignable, -> { current.includes(:project).where(:projects => { vacation: false }) }
  scope :unassignable, -> { current.includes(:project).where(:projects => { vacation: true }) }
  scope :billable, -> { where(billable: true) }
  scope :bound, -> { where(binding: true) }
  scope :with_start_date, lambda { |d| where("allocations.start_date <= ?", d.to_date + TIME_WINDOW.weeks).where("allocations.end_date >= ?", d.to_date).current }
  scope :vacation, -> { current.where(:projects => { vacation: true }) }
  scope :by_office, lambda { |office| office ? joins(:office).where("people.office_id" => office.id) : where(false) }
  scope :includes_provisional, lambda { |x| x ? where(nil) : where(provisional: false) }

  scope :billable_and_assignable, -> { billable.assignable }

  delegate :name, to: :project, prefix: true, :allow_nil => true

  def duration_in_hours
    duration_in_days * 8
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

  private

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

  private

  def clean_up_revenue
    # NOTE: this is a bit tricky. Future revenue can be destroyed, but
    #       past revenue has been reported and should not be destroyed
    #
    revenue_items.future.destroy_all
    revenue_items.past.update_all(allocation_id: nil)
  end
end
