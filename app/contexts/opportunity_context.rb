class OpportunityContext

  def self.all
    persons = Person.where(role: ['Business Development', 'Principal', 'Managing Director', 'General & Administrative'])
    offices = Office.where("slug NOT SIMILAR TO '(dublin|headquarters|archived)'")
    CrmData.new(Opportunity.all, persons, offices, Company.all, Contact.all, OpportunityNote.all)
  end

  def initialize(person)
    @person = person
  end

  def create_opportunity(params=nil)
    extra_params = prepare_opportunity_extra_params(params) unless params.nil?

    opportunity = Opportunity.new(params)
    set_default_values_for(opportunity)
    set_opportunity_relations(opportunity, extra_params)

    if opportunity.save
      opportunity
    else
      {error: opportunity.errors}
    end
  end

  def update_opportunity(opportunity_id, params)
    extra_params = prepare_opportunity_extra_params(params) unless params.nil?

    opportunity = Opportunity.find(opportunity_id)

    if opportunity
      opportunity.update_attributes(params)
      set_opportunity_relations(opportunity, extra_params)

      opportunity.save
      opportunity
    else
      {error: "there's no opportunity with that id"}
    end
  end

  def destroy_opportunity(opportunity_id)
    opportunity = Opportunity.find(opportunity_id)

    if opportunity
      opportunity.destroy
      nil
    else
      {error: "there's no opportunity with that id"}
    end
  end

  private

  def prepare_opportunity_extra_params(params)
    params.delete(:created)
    params.delete(:updated)

    {
      # contact: {id: params.delete(:contact_id), name: params.delete(:contact_name), email: params.delete(:contact_email), phone: params.delete(:contact_phone)},
      contact: params.delete(:contact),
      company: params.delete(:company),
      owner: params.delete(:owner),
      office: params.delete(:office)
    }
  end

  def set_opportunity_relations(opportunity, relationship_params)
    unless relationship_params.nil?
      get_contact(relationship_params[:contact], opportunity) unless relationship_params[:contact].nil?
      get_company(relationship_params[:company], opportunity) unless relationship_params[:company].nil?

      set_contact_company(opportunity)
      get_owner(relationship_params[:owner], opportunity) unless relationship_params[:owner].nil?
      set_office(relationship_params[:office], opportunity) unless relationship_params[:office].nil?
    end
  end

  def set_default_values_for(opportunity)
    opportunity.title = opportunity.title || "#{@person.name}'s new opportunity"
    opportunity.confidence = opportunity.confidence || 'warm'
    opportunity.stage = opportunity.stage || 'idea'
    opportunity.status = nil
    opportunity.person = @person
    opportunity.office = @person.office
  end

  def get_contact(contact_id, opportunity)
    # contact = Contact.where(email: contact_params[:email]).first if !contact_params[:email].nil? or contact_params[:email] != ''
    # contact ||= Contact.create(contact_params) if contact_params[:email] != '' and !contact_params[:email].nil?

    opportunity.contact = Contact.find(contact_id)
  end

  def get_company(company_id, opportunity)
    # company = Company.find(company_params[:id]) unless company_params[:id].nil?
    opportunity.company = Company.find(company_id)
    # company = (Company.where("name ILIKE ?", company_params[:name]).first || Company.create(name: company_params[:name])) if !company_params[:name].nil? and company.nil?
  end

  def set_contact_company(opportunity)
    contact = opportunity.contact
    company = opportunity.company

    unless contact.nil?
      if !company.nil? and contact.company.nil?
        contact.company = company
        contact.save
      elsif !contact.company.nil? and company.nil?
        opportunity.company = contact.company
      end
    end
  end

  def get_owner(owner, opportunity)
    unless owner.nil?
      person = Person.find(owner)
      opportunity.person = person unless person.nil?
    end
  end

  def set_office(office_id, opportunity)
    office = Office.find(office_id)
    opportunity.office = office unless office.nil?
  end
end
