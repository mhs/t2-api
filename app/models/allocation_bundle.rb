class AllocationBundle
  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def projects
    Project.all.map do |project|
      DateRangeProject.new project, @start_date, @end_date
    end
  end

  def allocations
    Allocation.between @start_date, @end_date
  end

  def offices
    Office.all.map do |office|
      DateRangeOffice.new office, @start_date, @end_date
    end
  end

  def people
    Person.employed_between @start_date, @end_date
  end

  alias read_attribute_for_serialization send

  def active_model_serializer
    AllocationBundleSerializer
  end
end
