class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :binding, :slot, :slot_id, :person, :person_id, :project, :project_id

  TIME_WINDOW = 20 # weeks

  belongs_to :slot
  belongs_to :person
  belongs_to :project
  has_one :office, through: :person

  validates :person_id, :project_id, :start_date, :end_date, presence: true
  validates_date :end_date, on_or_after: :start_date

  scope :current, includes(:project).where("projects.deleted_at is NULL")
  scope :between_date_range, lambda { |start_date, end_date|
    where("allocations.start_date >= ?", start_date.to_date)
    .where("allocations.end_date <= ?", end_date.to_date)
  }
  scope :for_date, lambda {|d|
    joins(:project)
    .where("projects.id IS NOT NULL")
    .where("allocations.start_date <= ?", d.to_date)
    .where("allocations.end_date >= ?", d.to_date)
  }
  scope :on_date, lambda { |d| for_date(d).current }
  scope :this_year, lambda { between_date_range(Date.today.beginning_of_year, Date.today.end_of_year).current }
  scope :assignable, current.includes(:project).where(:projects => { vacation: false })
  scope :unassignable, current.includes(:project).where(:projects => { vacation: true })
  scope :billable, where(billable: true)
  scope :with_start_date, lambda { |d| where("allocations.start_date <= ?", d.to_date + TIME_WINDOW.weeks).where("allocations.end_date >= ?", d.to_date).current }
  scope :vacation, current.includes(:project).where(:projects => { vacation: true })
  scope :for_person, lambda { |person_or_id| joins(:person).where("people.id = ?", person_or_id.is_a?(Fixnum) ? person_or_id : person_or_id.id) }
  scope :by_office, lambda { |office| office ? joins(:office).where("people.office_id" => office.id) : where(false) }

  delegate :name, to: :project, prefix: true, :allow_nil => true
end
