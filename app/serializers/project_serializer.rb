class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :vacation,
             :investment_fridays, :rates, :billable, :num_weeks_per_invoice

  has_many :offices, embed: :ids
  has_one :selling_office, embed: :ids
  has_many :people, embed: :ids, include: true

end
