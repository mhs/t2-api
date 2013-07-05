class OfficeSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes
  
  has_many :projects, embed: :ids
  has_many :people, embed: :ids

  # def people_ids
  # 	people_ids = object.current_people.map(&:id)
  # 	"#{people_ids}"
  # end
end
