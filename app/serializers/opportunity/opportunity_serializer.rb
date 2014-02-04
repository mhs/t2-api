class Opportunity::OpportunitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :stage, :confidence, :amount, :expected_date_close, :next_step,
    :owner, :company, :contact, :office, :opportunity_notes, :created, :updated, :status

  embed :ids, include: true

  def expected_date_close
    return nil if object.expected_date_close.nil?
    object.expected_date_close.strftime(time_format)
  end

  def owner
    object.person.id
  end

  def company
    object.company_id
  end

  def contact
    object.contact_id
  end

  def office
    object.office_id
  end

  def opportunity_notes
    object.opportunity_notes.select(:id).map{ |note| note.id }
  end

  def created
    object.created_at.strftime(time_format)
  end

  def updated
    object.updated_at.strftime(time_format)
  end

  private

  def time_format
    '%d-%m-%Y'
  end
end
