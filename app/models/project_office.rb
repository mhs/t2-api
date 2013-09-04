class ProjectOffice < ActiveRecord::Base
  attr_accessible :project, :office, :allowance
  belongs_to :project
  belongs_to :office

  validates :allowance, numericality: { only_integer: true, allow_nil: true, greater_than: 0 }
end

