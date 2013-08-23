class Person < ActiveRecord::Base
  acts_as_paranoid
  acts_as_taggable_on :skills

  attr_accessible :name, :notes, :email, :unsellable, :office, :office_id, :start_date, :end_date

  has_many :allocations
  belongs_to :office
  belongs_to :project

  scope :employed_on_date, lambda { |d|
    where("start_date is NULL or start_date < ?",d)
    .where("end_date is NULL or end_date > ?", d)
  }
  scope :overhead, where(unsellable: true)
  scope :billable, where(unsellable: false)
  scope :by_office, lambda {|office| office ? where(office_id: office.id) : where(false) }

  def self.unassignable_on_date(date, office=nil)
    # Unsellable = ALWAYS overhead (e.g. the CEO)
    # Unassignable = Usually available to be assigned, but out on vacation or something like that
    eligible_employees = by_office(office).billable.employed_on_date(date)
    Allocation.by_office(office).on_date(date).unassignable.map(&:person).select{|p| eligible_employees.include?(p)}.uniq
  end

  def self.billing_on_date(date, office=nil)
    on_vacation = unassignable_on_date(date, office)
    Allocation.by_office(office).on_date(date).billable.assignable.map(&:person).reject{|p| on_vacation.include?(p)}.uniq
  end

  def pto_requests
    allocations.this_year.vacation
  end
end
