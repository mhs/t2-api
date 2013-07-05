class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :slot_id, :person_id, :project_id, :billable, :binding

  belongs_to :slot
  belongs_to :person
  belongs_to :project

  scope :current, includes(:project).where("projects.deleted_at is NULL")
  scope :for_date, lambda { |d| where("start_date <= ?",d.to_date).where("end_date >= ?", d.to_date) }
  scope :today, lambda { for_date(Date.today).current }
  scope :assignable, current.includes(:project).where(:projects => { vacation: false })
end
