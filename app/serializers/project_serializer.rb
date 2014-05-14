class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :provisional, :vacation, :rates

  has_many :offices, embed: :ids
  has_many :people, embed: :ids, include: true
  has_one :selling_office, embed: :ids

  def selling_office
    object.offices.sample
  end
end
