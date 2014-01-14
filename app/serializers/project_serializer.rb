class ProjectSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :notes, :billable, :vacation, :start_date, :end_date
  # has_many :slots
  has_many :offices, embed: :ids
  has_many :allocations, embed: :ids
end
