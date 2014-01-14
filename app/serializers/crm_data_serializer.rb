class CrmDataSerializer < ActiveModel::Serializer
  has_many :opportunities, embed: :objects
  has_many :people, embed: :objects, serializer: OpportunityOwnerSerializer
  has_many :business_units, embed: :objects, serializer: OpportunityBusinessUnitSerializer
  has_many :companies, embed: :objects, serializer: OpportunityCompanySerializer
  has_many :contacts, embed: :objects, serializer: OpportunityContactSerializer
end
