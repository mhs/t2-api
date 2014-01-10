class CrmData
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport

  attr_accessor :opportunities, :people, :business_units

  def initialize(opportunities, people, business_units)
    @opportunities = opportunities
    @people = people
    @business_units = business_units
  end
end
