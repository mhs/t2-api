class Holiday < ActiveRecord::Base
  has_many :office_holidays, :inverse_of => :holiday
  has_many :offices, :through => :office_holidays

  scope :upcoming, -> { where('start_date >= ?', Date.today) }

  before_destroy { allocations.destroy_all }

  def self.declare(name, offices, start_date, end_date=nil)
    holiday = create! do |h|
      h.name = name
      h.start_date = start_date
      h.end_date = (end_date || start_date)
    end

    Person.within_date_range(Date.today, 1.year.from_now) do
      offices.each do |office|
        office.holidays << holiday
        office.people.each do |person|
          _allocate_holiday(holiday, person)
        end
      end
    end

    holiday
  end

  def add_person(person)
    self.class._allocate_holiday(self, person)
  end

  def self._allocate_holiday(holiday, person)
    project = Project.holiday_project

    person.allocations.create! do |a|
      a.project = project
      a.start_date = holiday.start_date
      a.end_date = holiday.end_date
      a.billable = false
      a.binding = true
      a.notes = holiday.name
      a.likelihood = '100% Booked'
    end
  end

  def allocations
    project = Project.holiday_project

    project.allocations.where(start_date: start_date, end_date: end_date)
  end
end
