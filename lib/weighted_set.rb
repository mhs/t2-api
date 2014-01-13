require 'delegate'

class WeightedSet < DelegateClass(Hash)

  def initialize(initial = {})
    super(initial)
  end

  def -(other)
    result = {}
    this.each_pair do |k, v|
      result[k] = this[k] - (other[k] || 0)
    end
    self.class.new(result)
  end

  def +(other)
    result = this.dup
    other.each_pair do |k, v|
      result[k] = (this[k] || 0) + other[k]
    end
    self.class.new(result)
  end

  def total
    this.values.reduce(:+)
  end

  def compact
    result = {}
    this.each_pair do |k, v|
      result[k] = this[k] if v != 0
    end
    self.class.new(result)
  end

  def ==(other)
    other.is_a?(self.class) && this == other.send(:this)
  end

  private

  # JS devs see me trollin
  def this
    __getobj__
  end
end
