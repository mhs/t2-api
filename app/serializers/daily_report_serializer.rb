class DailyReportSerializer < ActiveModel::Serializer

  attributes :report_date

  has_many :snapshots
  has_many :offices

  def snapshots
    object.snapshots
  end

  def offices
    object.snapshots.map(&:office)
  end
end
