class AllocationBundleSerializer < ActiveModel::Serializer
  attributes :id
  embed :ids, include: true

  has_many :offices
  has_many :allocations
  has_many :projects
  has_many :people

  def id
    1
  end
end
