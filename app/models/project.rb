class Project < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :billable, :binding, :slug, :client_principal_id, :vacation, :start_date, :end_date

  has_one   :client_principal, class_name: "Person"
  has_many  :project_offices
  has_many  :offices, through: :project_offices
  has_many  :slots
  has_many_current  :allocations
  has_many  :project_allowances, inverse_of: :project

  acts_as_paranoid

  scope :assignable, -> { where(vacation: true) }

  def allowance_for_office(office_id)
    project_offices.where(office_id: office_id).first.try(:allowance)
  end
end
