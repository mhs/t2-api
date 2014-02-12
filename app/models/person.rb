class Person < ActiveRecord::Base
  include HasManyCurrent

  ROLES = [
    'Apprentice',
    'Business Development',
    'Designer',
    'Developer',
    'General & Administrative',
    'Managing Director',
    'Principal',
    'Product Manager',
    'Support Staff'
  ]

  acts_as_paranoid
  acts_as_taggable_on :skills

  attr_accessible :name, :notes, :email, :office, :office_id, :start_date, :end_date,
                  :github, :twitter, :website, :title, :bio, :skill_list, :avatar, :role, :percent_billable

  has_attached_file :avatar,
                      styles: { medium: "300x300>", small: "100x100>", thumb: "50x50>" },
                      default_url: "https://t2-data.s3.amazonaws.com/default.png"

  belongs_to  :user, inverse_of: :person
  has_many_current :allocations
  belongs_to  :office
  belongs_to  :project
  has_many    :project_allowances, inverse_of: :person
  has_many    :opportunity_notes
  has_many    :opportunities

  validates :name, presence: true
  validates :office, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@([^.\s]+\.)+([^.\s]+)\Z/i }
  validates :user_id, presence: true, on: :update

  validates :role, inclusion: { in: ROLES }, allow_blank: true

  validates :percent_billable, inclusion: {in: 0..100}

  scope :employed_on_date, lambda { |d|
      where("people.start_date IS NULL OR people.start_date <= ?",d)
     .where("people.end_date IS NULL OR people.end_date >= ?", d)
  }

  scope :employed_between, -> start_date, end_date do
    where(
      "(people.start_date IS NULL OR people.start_date <= :end_date) AND (people.end_date IS NULL OR people.end_date >= :start_date)",
      {start_date: start_date, end_date: end_date}
    )
  end

  scope :overhead, -> { where("percent_billable < 100") }
  scope :billable, -> { where("percent_billable > 0") }
  scope :by_office, lambda { |office| office.try(:id) ? where(office: office) : where(false) }

  after_create :create_or_associate_user, :create_missing_project_allowances

  def self.editable_attributes
    accessible_attributes.to_a - ['office', 'office_id']
  end

  def self.from_auth_token(token)
    joins(:user).where("users.authentication_token = ?", token).first
  end

  def pto_requests
    allocations.this_year.vacation
  end

  def allocations_for_project(project_id)
    allocations.this_year.where(project_id: project_id)
  end

  def utilization(start_date=nil, end_date=nil)
    Utilization.new(self, start_date, end_date).to_hash
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

  def similar_people(limit=nil)
    skilled_people_hash = {}

    self.skill_list.each do |skill|
      Person.tagged_with(skill).each do |person|
        next if person == self
        skilled_people_hash[person.id] = {
          count: (skilled_people_hash.fetch(person.id, {}).fetch(:count, 0) + 1),
          person: person
        }
      end
    end

    values = skilled_people_hash.values.sort_by! do |obj|
      obj[:count]
    end.reverse

    values[0..(limit.to_i-1)].map do |obj|
      obj[:person]
    end
  end

  def availabilities_for(start_date, end_date)
    min_start_date = self.start_date.nil? ? start_date : [self.start_date,start_date].max
    max_end_date = self.end_date.nil? ? end_date : [self.end_date,end_date].min

    allocations_within_range = allocations.bound.within(start_date, end_date)
    initial_availability = Availability.new(person_id: id, start_date: min_start_date, end_date: max_end_date, percent_allocated: percent_billable)

    AvailabilityCalculator.new(allocations_within_range, initial_availability).availabilities
  end

  def skill_list=(v)
    # DO NOTHING
    # something's b0rked with ActsAsTaggableOn::Tag and mass assignment
  end

  def employed_between?(start_window, end_window)
    (start_date.nil? || start_date <= end_window) && (end_date.nil? || end_date >= start_window)
  end

  private

  def create_or_associate_user
    self.user = User.find_or_create_by!(:email => email.downcase) do |u|
      u.name = name
    end

    save
  end
end
