class UtilizationGroup
  attr_accessor :utilizations

  def initialize(people:, **args)
    @utilizations = people.uniq.map do |p|
      Utilization.new(person: p, **args)
    end
  end

  def billable_percentages
    fetch(:billable_percentage)
  end

  def non_billable_percentages
    fetch(:non_billable_percentage).compact
  end

  def unassigned_percentages
    fetch(:unassigned_percentage).compact
  end

  def billing_percentages
    fetch(:billing_percentage).compact
  end

  def assignable_percentages
    fetch(:assignable_percentage).compact
  end

  def non_billing_percentages
    fetch(:non_billing_percentage).compact
  end

  def overallocated_percentages
    fetch(:overallocated_percentage).compact
  end

  def assignable_percentages
    fetch(:assignable_percentage).compact
  end

  def utilization_percentage
    return "0.0" if assignable_percentages.empty?
    sprintf "%.1f", (100.0 * billing_percentages.total) / assignable_percentages.total
  end

  private

  def fetch(key)
    result = utilizations.each_with_object({}) do |u, hash|
      hash.merge!(u.to_hash(key))
    end
    FteWeightedSet.new(result).person_named_keys
  end
end
