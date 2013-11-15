class UtilizationSummarySerializer < ActiveModel::Serializer
  attributes :id, :office_id, :office_name, :office_slug

  has_many :utilization_counts, embed: :ids, include: true
  has_one :snapshot, embed: :ids, include: true

end
