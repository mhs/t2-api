class ProjectSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :notes, :billable, :vacation
  has_many :slots
  has_many :offices
  has_many :allocations
end
