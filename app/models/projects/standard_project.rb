# TODO: Expand standard project into some (if not all):
#   vacation, validation, coaching ...etc
#
class StandardProject < Project

  NON_BILLING_ROLES = [
    'Apprentice',
    'Business Development',
    'General & Administrative',
    'Support Staff'
  ]

  ALIASED_ROLES = {
    'Managing Director' => 'Principal'
  }

  def rate_for(role)
    return 0.0 if NON_BILLING_ROLES.include?(role)

    rate = rates[role] || rates[ALIASED_ROLES[role]]
    rate.to_f / (investment_fridays? ? 4 : 5)
  end

end
