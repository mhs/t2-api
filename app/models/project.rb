class Project < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :billable, :binding, :provisional, :slug, :client_principal_id, :vacation, :start_date, :end_date, :office_ids

  has_one   :client_principal, class_name: "Person"
  has_many  :project_offices
  has_many  :offices, through: :project_offices
  has_many_current  :allocations

  acts_as_paranoid

  scope :assignable, -> { where(vacation: true) }

  def self.holiday_project
    where(holiday: true).first
  end

end
