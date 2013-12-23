class DateRangeProject < DelegateClass(Project)
  delegate :id, :to => :__getobj__

  attr_accessor :start_date, :end_date

  def initialize(project, start_date, end_date)
    super(project)
    @start_date = start_date
    @end_date = end_date
  end

  def allocations
    # filter in-memory
    super.between @start_date, @end_date
  end
end
