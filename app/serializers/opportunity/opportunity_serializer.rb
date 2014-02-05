class Opportunity::OpportunitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :stage, :confidence, :amount, :expected_date_close, :next_step,
    :owner, :owner_id,
    :company, :company_id, :company_name,
    :contact, :contact_id, :contact_name, :contact_email,
    :office, :office_id,
    :opportunity_notes

  embed :ids, include: true

  def expected_date_close
    Time::DATE_FORMATS[:day_month_year] = '%d-%m-%Y'
    return nil if object.expected_date_close.nil?
    object.expected_date_close.to_s(:day_month_year)
  end

  def owner
    object.person.id
  end

  def owner_id
    owner
  end

  def company
    object.company_id
  end

  def company_id
    company
  end

  def company_name
    object.company.name unless object.company.nil?
  end

  def contact
    object.contact_id
  end

  def contact_id
    contact
  end

  def office
    object.office_id
  end
  
  def office_id
    office
  end

  def contact_name
    object.contact.name unless object.contact.nil?
  end

  def contact_email
    object.contact.email unless object.contact.nil?
  end
end