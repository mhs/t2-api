class DailyReport

  include ActiveModel::Serializers::JSON

  attr_accessor :report_date, :snapshots

  def attributes
    {'report_date' => report_date, 'snapshots' => snapshots}
  end

  def self.on_date(date)
    daily_report = new
    daily_report.report_date = date
    daily_report.snapshots = []

    Office.all.each do |office|
      daily_report.snapshots << Snapshot.on_date!(date, office)
    end

    daily_report
  end
end
