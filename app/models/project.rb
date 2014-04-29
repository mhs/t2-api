class Project < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :billable, :binding, :provisional, :slug, :client_principal_id, :vacation, :start_date, :end_date, :office_ids

  has_one :client_principal, class_name: "Person"
  has_many :project_offices
  has_many :offices, through: :project_offices
  has_many :revenue_items, inverse_of: :project
  has_many_current :allocations
  has_many_current :people, through: :allocations

  acts_as_paranoid

  after_update :update_provisional_allocations

  scope :assignable, -> { where(vacation: true) }

  def self.holiday_project
    where(holiday: true).first
  end

  # TODO: make this configurable per-project
  # this is per-day internally, but may need to be cooked on input
  def rate_for(role)
    {
      'Apprentice' => 0.0,
      'Business Development' => 0.0,
      'Designer' => 7000.0,
      'Developer' => 7000.0,
      'General & Administrative' => 0.0,
      'Managing Director' => 14000.0,
      'Principal' => 14000.0,
      'Product Manager' => 10000.0,
      'Support Staff' => 0.0
    }[role]
  end

  protected

  def update_provisional_allocations
    # if we have changed from provisional to not, update the
    # allocations to match
    return unless !provisional? && provisional_was
    allocations.update_all(provisional: false)
  end
end
