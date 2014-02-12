class ProjectOffice < ActiveRecord::Base
  attr_accessible :project, :office, :project_id
  belongs_to :project
  belongs_to :office
  has_many   :employees, through: :office, source: :people

  scope :has_allowance, -> { where 'allowance > 0' }

end
