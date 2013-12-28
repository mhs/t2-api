class OpportunityContext

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

  private

  def prepare_opportunity_extra_params(params)
    {
      contact: params.delete(:contact),
      company: params.delete(:company),
      owner: params.delete(:owner)
    }
  end

  def set_opportunity_relations(opportunity, relationship_params)
    unless relationship_params.nil?
      get_contact(relationship_params[:contact], opportunity) unless relationship_params[:contact].nil?
      get_company(relationship_params[:company], opportunity) unless relationship_params[:company].nil?

      set_contact_company(opportunity)
      get_owner(relationship_params[:owner], opportunity) unless relationship_params[:owner].nil?
    end
  end

  def set_default_values_for(opportunity)
    opportunity.title = opportunity.title || "#{@person.name}'s new opportunity"
    opportunity.confidence = opportunity.confidence || 'warm'
    opportunity.stage = opportunity.stage || 'new'
    opportunity.person = @person
  end

  def get_contact(contact_params, opportunity)
    contact = Contact.where(email: contact_params[:email]).first unless contact_params[:email].nil?
    contact ||= Contact.create(contact_params)

    opportunity.contact = contact
  end

  def get_company(company_params, opportunity)
    company = Company.find(company_params[:id]) unless company_params[:id].nil?
    company = (Company.where("name ILIKE ?", company_params[:name]).first || Company.create(name: company_params[:name])) if !company_params[:name].nil? and company.nil?

    opportunity.company = company unless company.nil?
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
    unless owner[:id].nil?
      person = Person.find(owner[:id])
      opportunity.person = person unless person.nil?
    end
  end
end
