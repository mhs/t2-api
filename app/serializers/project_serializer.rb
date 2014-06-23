class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :provisional, :vacation,
             :investment_fridays, :rates, :typical_allocation_percentages,
             :typical_counts, :num_weeks_per_invoice, :billable

  has_many :offices, embed: :ids
  has_one :selling_office, embed: :ids
  has_many :people, embed: :ids, include: true

end
