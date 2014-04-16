class Availability

  attr_accessor :person_id, :start_date, :end_date, :percent_allocated

  def initialize(params)
    params.map { |k, v| send("#{k}=", v) }
  end

  def active_model_serializer
    AvailabilitySerializer
  end

  def id
    "#{person_id}-#{start_date}-#{end_date}-#{percent_allocated}"
  end

  def ==(other)
    self.person_id == other.person_id &&
      self.start_date === other.start_date &&
      self.end_date === other.end_date &&
      self.percent_allocated == other.percent_allocated
  end

  def similar(params)
    # TODO: should we do something more useful with % allocated?
    opts = {person_id: person_id, start_date: start_date, end_date: end_date, percent_allocated: percent_allocated}.merge(params)
    self.class.new(opts) if opts[:percent_allocated] > 0
  end

  def remove_range(range_start, range_end, range_allocated)
    # remove dates between range_start and range_end
    # returns an array of availability objects
    return [self] if range_end < start_date || range_start > end_date

    leftover = percent_allocated - range_allocated
    if range_start <= start_date && range_end >= end_date
      # range is larger than our interval and covers it
      [similar(percent_allocated: leftover)]
    elsif range_start <= start_date
      # trimming from the start
      [
        similar(end_date: range_end, percent_allocated: leftover),
        similar(start_date: range_end + 1.day)
      ]
    elsif range_end >= end_date
      # trimming from the end
      [
        similar(end_date: range_start - 1.day),
        similar(start_date: range_start, percent_allocated: leftover)
      ]
    else
      # in the middle
      [
        similar(end_date: range_start - 1.day),
        similar(start_date: range_start, end_date: range_end, percent_allocated: leftover),
        similar(start_date: range_end + 1.day)
      ]
    end.compact
  end

  def remove_weekends!
    self.start_date = start_date.following_monday if start_date.weekend?
    self.end_date = end_date.preceding_friday if end_date.weekend?
  end

  def empty?
    end_date < start_date
  end

  alias read_attribute_for_serialization send
end
