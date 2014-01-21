class Opportunity::OpportunityNoteSerializer < ActiveModel::Serializer
  attributes :id, :detail, :owner

  def owner
    {
      id: object.person.id,
      name: object.person.name,
      email: object.person.email
    }
  end
end
