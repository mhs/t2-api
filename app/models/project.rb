class Project < ActiveRecord::Base
  attr_accessible :name, :notes, :billable, :office_id, :binding, :slug, :client_principal_id, :vacation

  has_many :project_offices
  has_many :offices, :through => :project_offices
  has_many :slots
  has_many :allocations

end
