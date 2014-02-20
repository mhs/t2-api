require 'weighted_set'

class FteWeightedSet < WeightedSet
  def to_fte
    (total / 100.0)
  end

  def person_named_keys
    transform_keys { |person| person.name }
  end

  def invert_percentages
    transform_values { |v| 100 - v }
  end
end
