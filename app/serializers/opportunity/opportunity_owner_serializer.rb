class Opportunity::OpportunityOwnerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role
end
