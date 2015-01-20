module UtilizationMailerHelper

  def monthly_snapshot_title(snapshot)
    date = snapshot.snap_date
    suffix = date.future? ? " Forecast" : nil
    "Monthly Utilization#{suffix}: #{date.to_s(:short)} - #{date.end_of_month.to_s(:short)} #{date.year}"
  end

  def person_utilization(name, percent, suppress=true)
    suppress && percent == 100 ? name : "#{name} (#{percent}%)"
  end

  def fte_grouped_by_office(fte_weighted_set)
    all_people = Person.where(name: fte_weighted_set.keys).group_by {|p| p.office.name}
    people_by_office = all_people.reduce({}) do |memo, (office, people)|
      utilizations = {}
      people.each do |person|
        utilizations[person.name] = fte_weighted_set[person.name]
      end

      memo[office] = utilizations
      memo
    end
    people_by_office.sort.to_h
  end
end
