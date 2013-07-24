class Project < ActiveRecord::Base
  attr_accessible :name, :notes, :billable, :binding, :slug, :client_principal_id, :vacation

  has_one :client_principal, class_name: "Person"
  has_many :project_offices
  has_many :offices, :through => :project_offices
  has_many :slots
  has_many :allocations

  acts_as_paranoid

  scope :assignable, where(vacation: true)

end
