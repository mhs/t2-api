class CrmDataSerializer < ActiveModel::Serializer
  has_many :opportunities, serializer: Opportunity::OpportunitySerializer
  has_many :people, serializer: Opportunity::OpportunityOwnerSerializer
  has_many :business_units, serializer: Opportunity::OpportunityBusinessUnitSerializer
  has_many :companies, serializer: Opportunity::OpportunityCompanySerializer
  has_many :contacts, serializer: Opportunity::OpportunityContactSerializer
  has_many :opportunity_notes, serializer: Opportunity::OpportunityNoteSerializer
end
