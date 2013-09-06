class AllowanceCalculator
  attr_reader :person, :project
  def initialize person, project
    @person = person
    @project = project
  end

  def exceeds_allowance? hours_to_be_allocated
    hours_to_be_allocated + hours_spent > (project.allowance_for_office(person.office_id) || Float::INFINITY)
  end

  def hours_spent
    person.allocations_for_project(project.id).map(&:duration_in_hours).inject(0, :+)
  end
end
