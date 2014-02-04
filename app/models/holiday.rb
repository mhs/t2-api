class Holiday < ActiveRecord::Base
  has_many :office_holidays, :inverse_of => :holiday
  has_many :offices, :through => :office_holidays

  def self.declare(name, offices, start_date, end_date=nil)
    holiday = create! do |h|
      h.name = name
      h.start_date = start_date
      h.end_date = (end_date || start_date)
    end

    project = Project.holiday_project

    Person.within_date_range(Date.today, 1.year.from_now) do
      offices.each do |office|
        office.holidays << holiday
        office.people.each do |person|
          person.allocations.create! do |a|
            a.project = project
            a.start_date = holiday.start_date
            a.end_date = holiday.end_date
            a.billable = false
            a.binding = true
            a.notes = holiday.name
          end
        end
      end
    end

    holiday
  end
end
