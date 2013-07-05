class ProjectOffice < ActiveRecord::Base
  attr_accessible :project, :office
  belongs_to :project
  belongs_to :office
end

