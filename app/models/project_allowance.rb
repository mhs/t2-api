class ProjectAllowance < ActiveRecord::Base
  attr_accessible :hours

  belongs_to  :project, inverse_of: :project_allowances
  belongs_to  :person, inverse_of: :project_allowances

  def available
    hours - person.hours_allocated_to(project_id)
  end

  def used
    person.hours_allocated_to(project_id)
  end
end

