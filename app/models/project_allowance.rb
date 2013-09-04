class ProjectAllowance < ActiveRecord::Base
  attr_accessible :hours

  belongs_to  :project, inverse_of: :project_allowances
  belongs_to  :person, inverse_of: :project_allowances

end

