class SkillSerializer < ActiveModel::Serializer
  attributes :name, :count
  has_many :people, serializer: MinimumPersonSerializer
end
