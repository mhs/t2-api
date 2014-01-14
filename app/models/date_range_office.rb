class DateRangeOffice < DelegateClass(Office)
  delegate :id, :to => :__getobj__

  attr_accessor :start_date, :end_date

  def initialize(office, start_date, end_date)
    super(office)
    @start_date = start_date
    @end_date = end_date
  end

  def people
    # do this in-memory because people should be preloaded
    super.to_a.select do |person|
      person.employed_between?(@start_date, @end_date)
    end
  end

  def projects
    super.to_a.select do |project|
      # do nothing for now
      true
    end
  end
end
