class DateRangeOffice < DelegateClass(Office)
  delegate :id, :to => :__getobj__

  attr_accessor :start_date, :end_date

  def initialize(office, start_date, end_date)
    super(office)
    @start_date = start_date
    @end_date = end_date
  end

  def people
    super.employed_between @start_date, @end_date
  end
end
