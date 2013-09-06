class ProjectAllowance < ActiveRecord::Base
  attr_accessible :hours, :project_id, :person_id

  belongs_to  :project, inverse_of: :project_allowances
  belongs_to  :person, inverse_of: :project_allowances

  validates   :person_id, :project_id, presence: true

  def available
    hours - used
  end

  def used
    AllowanceCalculator.new(person, project).hours_spent
  end
end

