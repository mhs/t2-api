class OfficeHoliday < ActiveRecord::Base
  belongs_to :holiday, :inverse_of => :office_holidays
  belongs_to :office, :inverse_of => :office_holidays
end
