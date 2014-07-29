class AllocationsInDates

  def initialize(project, person)
    @project = project
    @person = person
  end

  def allocations_between(start, finish)
    start = date_convert(start)
    finish = date_convert(finish)
    @project.allocations
      .where({person:@person})
      .where("end_date >= :start", {start: start})
      .where("start_date <= :end", {end: finish})
      .map(&:week_days)
      .flatten
      .reject{|d| d < start || d > finish }
      .count
  end


  private

  def date_convert(date)
    return Date.parse(date) if date.is_a?(String)
    date
  end


end
