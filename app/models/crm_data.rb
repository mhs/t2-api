class CrmData
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport

  attr_accessor :opportunities, :people, :business_units, :companies, :contacts

  def initialize(opportunities, people, business_units, companies, contacts)
    @opportunities = opportunities
    @people = people
    @business_units = business_units
    @companies = companies
    @contacts = contacts
  end
end
