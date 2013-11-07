class Availability

  attr_accessor :person_id, :start_date, :end_date

  def initialize(params)
    params.map { |k, v| send("#{k}=", v) }
  end

  def active_model_serializer
    AvailabilitySerializer
  end

  def ==(other)
    self.person_id == other.person_id &&
      self.start_date === other.start_date &&
      self.end_date === other.end_date
  end

  def similar(params)
    self.class.new({person_id: person_id, start_date: start_date, end_date: end_date}.merge(params))
  end

  def remove_range(range_start, range_end)
    # remove dates between range_start and range_end
    # returns an array of availability objects
    return [self] if range_end < start_date || range_start > end_date

    if range_start <= start_date && range_end >= end_date
      # range is larger than our interval and covers it
      []
    elsif range_start <= start_date
      # trimming from the start
      [similar(start_date: range_end + 1.day)]
    elsif range_end >= end_date
      # trimming from the end
      [similar(end_date: range_start - 1.day)]
    else
      # in the middle
      [similar(end_date: range_start - 1.day), similar(start_date: range_end + 1.day)]
    end
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
