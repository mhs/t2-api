require 'weighted_set'

class UtilizationGroup
  attr_accessor :utilizations

  def initialize(people, start_date=nil, end_date=nil)
    @utilizations = people.uniq.map do |p|
      Utilization.new(p, start_date, end_date)
    end
  end

  def fetch(key)
    result = utilizations.each_with_object({}) do |u, hash|
      hash.merge!(u.to_hash(key))
    end
    WeightedSet.new(result)
  end

  def assignable_weights
    (fetch(:billable_percentage) - fetch(:unassigned_percentage)).compact
  end

  def non_billing_weights
    (assignable_weights - fetch(:billing_percentage)).compact
  end

  def utilization_percentage
    if assignable_weights.empty?
      0.0
    else
      sprintf "%.1f", (100.0 * fetch(:billing_percentage).total) / assignable_weights.total
    end
  end
end
