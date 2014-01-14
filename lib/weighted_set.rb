require 'delegate'

class WeightedSet < DelegateClass(Hash)

  def initialize(initial = {})
    initial = Hash[initial] if initial.is_a?(Array)
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
    result = other.dup
    this.each_pair do |k, v|
      result[k] = this[k] + (other[k] || 0)
    end
    self.class.new(result)
  end

  def total
    this.values.reduce(:+)
  end

  def max(max_val)
    result = {}
    this.each_pair do |k, v|
      result[k] = [this[k], max_val].max
    end
    self.class.new(result)
  end

  def compact
    result = {}
    this.each_pair do |k, v|
      result[k] = this[k] if v != 0
    end
    self.class.new(result)
  end

  def ==(other)
    # this is tricky because Hash respects order but we don't want to
    other.is_a?(self.class) &&
      ((other.keys - this.keys) + (this.keys - other.keys)).empty? &&
      this.values_at(*other.keys) == other.values
  end

  def transform_keys
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    self.class.new(result)
  end

  private

  # JS devs see me trollin
  def this
    __getobj__
  end
end
