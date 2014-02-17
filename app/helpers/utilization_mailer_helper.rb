module UtilizationMailerHelper

  def monthly_snapshot_title(snapshot)
    date = snapshot.snap_date
    prefix = date.future? ? "Projected " : nil
    "#{prefix}Monthly Utilization Report: #{date.to_s(:short)} - #{date.end_of_month.to_s(:short)} #{date.year}"
  end

  def person_utilization(name, percent, suppress=true)
    suppress && percent == 100 ? name : "#{name} (#{percent}%)"
  end

end
