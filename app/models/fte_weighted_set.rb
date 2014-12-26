require 'weighted_set'

class FteWeightedSet < WeightedSet
  def to_fte
    f = (total / 100.0)
    f < 0 ? 0 : f
  end

  def person_named_keys
    transform_keys { |person| person.name }
  end
end
