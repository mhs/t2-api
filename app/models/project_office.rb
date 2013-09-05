class ProjectOffice < ActiveRecord::Base
  attr_accessible :project, :office, :allowance, :project_id
  belongs_to :project
  belongs_to :office
  has_many   :employees, through: :office, source: :people

  validates :allowance, numericality: { only_integer: true, allow_nil: true, greater_than: 0 }

  scope :has_allowance, -> { where 'allowance > 0' }

  after_save :create_missing_project_allowances

  private
  def create_missing_project_allowances
    employees.each &:create_missing_project_allowances
  end
end

