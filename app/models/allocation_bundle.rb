class AllocationBundle
  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def projects
    Project.within_date_range(@start_date, @end_date) do
      Project.includes(:offices, :allocations).to_a
    end
  end

  def allocations
    Allocation.within(@start_date, @end_date).to_a
  end

  def offices
    Office.within_date_range(@start_date, @end_date) do
      Office.includes(:projects, :people).to_a
    end
  end

  def people
    Person.within_date_range(@start_date, @end_date) do
      Person.includes(:office, :user, :allocations => :project).to_a
    end
  end

  alias read_attribute_for_serialization send

  def active_model_serializer
    AllocationBundleSerializer
  end

end
