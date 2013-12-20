class OpportunitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :stage, :confidence, :amount, :expected_date_close, :owner, :company, :contact, :opportunity_notes

  def owner
    {
      id: object.person.id,
      name: object.person.name,
      email: object.person.email
    }
  end

  def company
    unless object.company.nil?
      {
        id: object.company.id,
        name: object.company.name
      }
    end
  end

  def contact
    unless object.contact.nil?
      {
        id: object.contact.id,
        name: object.contact.name,
        email: object.contact.email,
        phone: object.contact.phone
      }
    end
  end
end
