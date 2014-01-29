class CrmDataSerializer < ActiveModel::Serializer
  has_many :opportunities, embed: :objects, serializer: Opportunity::OpportunitySerializer
  has_many :people, embed: :objects, serializer: Opportunity::OpportunityOwnerSerializer
  has_many :business_units, embed: :objects, serializer: Opportunity::OpportunityBusinessUnitSerializer
  has_many :companies, embed: :objects, serializer: Opportunity::OpportunityCompanySerializer
  has_many :contacts, embed: :objects, serializer: Opportunity::OpportunityContactSerializer
  has_many :opportunity_notes, embed: :objects, serializer: Opportunity::OpportunityNoteSerializer
end
