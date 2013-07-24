class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :binding, :slot, :slot_id, :person, :person_id, :project, :project_id

  TIME_WINDOW = 20 # weeks

  belongs_to :slot
  belongs_to :person
  belongs_to :project

  scope :current, includes(:project).where("projects.deleted_at is NULL")
  scope :for_date, lambda { |d| where("start_date <= ?",d.to_date).where("end_date >= ?", d.to_date) }
  scope :today, lambda { for_date(Date.today).current }
  scope :assignable, current.includes(:project).where(:projects => { vacation: false })
  scope :unassignable, current.includes(:project).where(:projects => { vacation: true })
  scope :billable, where(billable: true)
  scope :with_start_date, lambda { |d| where("start_date <= ?", d.to_date + TIME_WINDOW.weeks).where("end_date >= ?", d.to_date).current }
end
