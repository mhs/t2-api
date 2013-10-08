class Person < ActiveRecord::Base
  acts_as_paranoid
  acts_as_taggable_on :skills

  attr_accessible :name, :notes, :email, :unsellable, :office, :office_id, :start_date, :end_date

  belongs_to  :user, inverse_of: :person
  has_many    :allocations
  belongs_to  :office
  belongs_to  :project
  has_many    :project_allowances, inverse_of: :person

  validates :email, uniqueness: true
  validates :user_id, presence: true, on: :update

  scope :employed_on_date, lambda { |d|
    where("start_date is NULL or start_date < ?",d)
    .where("end_date is NULL or end_date > ?", d)
  }
  scope :overhead, where(unsellable: true)
  scope :billable, where(unsellable: false)
  scope :by_office, lambda {|office| office ? where(office_id: office.id) : where(false) }

  after_create :create_or_associate_user, :create_missing_project_allowances

  def self.from_auth_token(token)
    joins(:user).where("users.authentication_token = ?", token).first
  end

  def self.unassignable_on_date(date, office=nil)
    # Unsellable = ALWAYS overhead (e.g. the CEO)
    # Unassignable = Usually available to be assigned, but out on vacation or something like that
    eligible_employees = by_office(office).billable.employed_on_date(date)
    Allocation.by_office(office).on_date(date).unassignable.map(&:person).select{|p| eligible_employees.include?(p)}.uniq
  end

  def self.billing_on_date(date, office=nil)
    on_vacation = unassignable_on_date(date, office)
    allocations = Allocation.by_office_and_date(office, date).includes(:person)
    billable_allocations = allocations.billable_and_assignable
    non_billable_allocations_that_still_count = allocations.unbillable_for_billable_projects
    relevant_people = (billable_allocations + non_billable_allocations_that_still_count).map(&:person).uniq.compact
    relevant_people - on_vacation
  end

  def pto_requests
    allocations.this_year.vacation
  end

  def allocations_for_project(project_id)
    allocations.this_year.where(project_id: project_id)
  end

  def create_missing_project_allowances
    ids = project_allowances.map(&:id).tap { |ids| ids << 0 if ids.empty? }
    office.project_offices.has_allowance.where("id NOT IN (?)", ids).each do |project_office|
      project_allowances.create(
        hours: project_office.allowance,
        project_id: project_office.project_id
      )
    end
  end

  private

  def create_or_associate_user
    self.user = User.find_or_create_by_email!(email) do |u|
      u.name = name
    end
  end
end
