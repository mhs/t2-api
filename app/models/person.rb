class Person < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :name, :notes, :email, :unsellable, :office_id, :start_date, :end_date

  has_many :allocations
  belongs_to :office

  scope :employed_on_date, lambda { |d| where("start_date is NULL or start_date < ?",d).where("end_date is NULL or end_date > ?", d) }
  scope :currently_employed, lambda { employed_on_date(Date.today) }

end
