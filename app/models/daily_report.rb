class DailyReport

  include ActiveModel::Serializers::JSON

  attr_accessor :report_date, :snapshots

  def attributes
    {'report_date' => report_date, 'snapshots' => snapshots}
  end

  def initialize(date)
    @report_date = date
    @snapshots   = []
  end

  def self.on_date(date)
    new(date).tap do |daily_report|
      Office.all.each do |office|
        daily_report.snapshots << Snapshot.on_date(date, office_id: office.id)
      end
    end
  end
end
