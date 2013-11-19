class UtilizationSummary
  attr_reader :id, :office_id, :office_name, :office_slug, :utilization_counts, :snapshot, :by_office_utilizations
  def initialize(params={})
    @office_id = params[:office_id]
    snap_date = params[:snap_date] || Date.today
    summary_start_date = params[:summary_start_date] || snap_date - 1.week
    summary_end_date = params[:summary_end_date] || snap_date + 1.week
    @snapshot = Snapshot.on_date!(snap_date, @office_id)
    context_snapshots = Office.where("name NOT IN (?)", ["Headquarters", "Archived"]).map do |office|
      Snapshot.on_date!(snap_date, office.id)
    end

    @by_office_utilizations = context_snapshots.map do |snap|
      {name: snap.office.name, utilization: snap.utilization.to_f}
    end

    @utilization_counts = UtilizationCount.for_weekdays_between(summary_start_date, summary_end_date, office_id)
  end

  def id
    snapshot.id
  end

  def office_name
    office.name
  end

  def office_slug
    office.slug
  end

  def active_model_serializer
    UtilizationSummarySerializer
  end

  alias read_attribute_for_serialization send

  private
  def office
    Office.where(id: @office_id).first || Office::SummaryOffice.new
  end

end
