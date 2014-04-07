class ProjectSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :notes, :billable, :provisional, :vacation, :start_date, :end_date
  has_many :offices, embed: :ids
  has_many :allocations, embed: :ids
end
