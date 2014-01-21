class Opportunity::OpportunityOwnerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
end
