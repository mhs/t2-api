class AllocationBundle
  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def projects
    Project.includes(:offices, :allocations).merge(allocations_scope).to_a

    # Project.all.map do |project|
    #   DateRangeProject.new project, @start_date, @end_date
    # end
  end

  def allocations
    allocations_scope.to_a
  end

  def offices
    records = Office.includes(:projects, :people).merge(Person.employed_between(@start_date, @end_date)).where('projects.deleted_at IS NULL').to_a
  end

  def people
    Person.employed_between(@start_date, @end_date).merge(allocations_scope).includes(:allocations).to_a
  end

  alias read_attribute_for_serialization send

  def active_model_serializer
    AllocationBundleSerializer
  end

  private

  def allocations_scope
    Allocation.within(@start_date, @end_date)
  end
end
