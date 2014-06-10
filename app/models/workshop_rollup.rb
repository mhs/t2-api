class WorkshopRollup

  include ActiveModel::Model

  attr_accessor :id, :name, :notes, :billable, :provisional, :vacation,
    :start_date, :end_date, :offices, :allocations

  def self.from_workshops(workshops)
    new({
      name: "Workshops",
      offices: workshops.flat_map(&:offices).uniq,
      allocations: workshops.flat_map(&:allocations).uniq
    })
  end

  def initialize(attributes={})
    super
    @id = 'lol'
    @billable ||= true
    @provisional ||= false
    @vacation ||= false
    @offices ||= []
    @allocations ||= []
  end

  alias read_attribute_for_serialization send

end
