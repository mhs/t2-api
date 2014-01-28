class Opportunity::OpportunityNoteSerializer < ActiveModel::Serializer
  attributes :id, :detail, :owner, :opportunity, :created_at

  def owner
    object.person.id
  end

  def opportunity
    object.opportunity_id
  end

  def created_at
    object.created_at.strftime('%d-%m-%Y %H:%M')
  end
end
