class PersonWithCurrentSerializer < PersonSerializer

  def include_allocations?
    false
  end

  has_many :current_allocations, embed: :ids, include: true, root: :allocations

  def current_allocations
    # no-longer-employed people will not have allocations loaded
    if object.end_date && object.end_date < Date.today
      []
    else
      object.allocations
    end
  end
end
