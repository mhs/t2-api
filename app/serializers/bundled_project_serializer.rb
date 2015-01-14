class BundledProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :billable, :vacation, :start_date, :end_date, :employed_allocation_ids
  has_many :offices, embed: :ids
  has_many :allocations, embed: :ids
end

def employed_allocation_ids
  object.employed_allocations.pluck(:id)
end
