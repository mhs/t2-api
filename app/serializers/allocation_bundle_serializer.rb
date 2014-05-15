class AllocationBundleSerializer < ActiveModel::Serializer
  attributes :id
  embed :ids, include: true

  has_many :offices
  has_many :allocations
  has_many :availabilities
  has_many :projects, serializer: BundledProjectSerializer
  has_many :people
  has_many :conflicts

  def id
    1
  end
end
