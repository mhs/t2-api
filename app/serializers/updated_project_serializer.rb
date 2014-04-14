class UpdatedProjectSerializer < ActiveModel::Serializer
  root :project
  attributes :id, :name, :notes, :billable, :provisional, :vacation, :start_date, :end_date

  has_many :allocations, embed: :ids, include: true
  has_many :offices, embed: :ids
end
