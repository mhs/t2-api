class Opportunity::OpportunityOwnerSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :role, :avatar

  def avatar
    begin
      object.avatar.url(:thumb)
    rescue
      ""
    end
  end
end
