module UtilizationMailerHelper

  def monthly_snapshot_title(snapshot)
    date = snapshot.snap_date
    suffix = date.future? ? " Forecast" : nil
    "Monthly Utilization#{suffix}: #{date.to_s(:short)} - #{date.end_of_month.to_s(:short)} #{date.year}"
  end

  def person_utilization(name, percent, suppress=true)
    suppress && percent == 100 ? name : "#{name} (#{percent}%)"
  end

end
