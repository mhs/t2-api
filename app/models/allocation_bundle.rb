class AllocationBundle
  extend Memoist
  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    load_conflicts
  end

  def projects
    Project.within_date_range(@start_date, @end_date) do
      Project.includes(:offices, :allocations).active_within(@start_date, @end_date).to_a
    end
  end
  memoize :projects

  def allocations
    @allocations_hash.values
  end
  memoize :allocations

  def offices
    Office.within_date_range(@start_date, @end_date) do
      Office.includes(:projects, :people).references(:projects).to_a
    end
  end
  memoize :offices

  def people
    Person.within_date_range(@start_date, @end_date) do
      Person.employed_between(@start_date, @end_date).includes(:office, :user, :allocations => :project).to_a
    end
  end
  memoize :people

  def conflicts
    @conflicts
  end

  def availabilities
    people.flat_map { |person| person.availabilities_for(start_date, end_date) }
  end
  memoize :availabilities

  alias read_attribute_for_serialization send

  def active_model_serializer
    AllocationBundleSerializer
  end

  private

  def load_conflicts
    @conflicts = people.flat_map { |person| person.conflicts_for(start_date, end_date) }

    @allocations_hash = Allocation.within(@start_date, @end_date)
      .joins(:person).merge(Person.employed_between(@start_date, @end_date))
      .index_by(&:id)

    @conflicts.each do |conflict|
      conflict.allocations.each do |alloc|
        @allocations_hash[alloc.id].conflicts << conflict
      end
    end
  end
end
