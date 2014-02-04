class Opportunity::OpportunityOwnerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role, :avatar

  def avatar
    object.avatar.url(:thumb)
  end
end
