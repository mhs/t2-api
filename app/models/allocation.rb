class Allocation < ActiveRecord::Base
  attr_accessible :notes, :start_date, :end_date, :billable, :slot_id, :person_id, :project_id, :billable, :binding

  belongs_to :slot
  belongs_to :person
  belongs_to :project

end
