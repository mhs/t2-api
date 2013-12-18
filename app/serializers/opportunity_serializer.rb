class OpportunitySerializer < ActiveModel::Serializer
  attributes :id, :title, :stage, :confidence, :amount, :expected_date_close, :owner, :company

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
end
