class Opportunity::OpportunityContactSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone
end
