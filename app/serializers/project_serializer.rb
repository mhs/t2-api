class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :provisional, :vacation,
             :investment_fridays, :rates

  has_many :offices, embed: :ids
  has_many :people, embed: :ids, include: true

end
