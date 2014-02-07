class CrmData
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport

  attr_accessor :opportunities, :people, :business_units, :companies, :contacts, :opportunity_notes

  def initialize(opportunities, people, business_units, companies, contacts, opportunity_notes)
    @opportunities = opportunities
    @people = people
    @business_units = business_units
    @companies = companies
    @contacts = contacts
    @opportunity_notes = opportunity_notes
  end
end
