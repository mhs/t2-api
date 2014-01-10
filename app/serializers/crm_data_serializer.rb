class CrmDataSerializer < ActiveModel::Serializer
  has_many :opportunities, embed: :objects
  has_many :people, embed: :objects, serializer: OpportunityOwnerSerializer
  has_many :business_units, embed: :objects, serializer: OpportunityBusinessUnitSerializer
end
