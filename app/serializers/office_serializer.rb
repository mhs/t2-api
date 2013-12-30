class OfficeSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :slug, :position

  has_many :projects, embed: :ids
  has_many :people, embed: :ids

end
