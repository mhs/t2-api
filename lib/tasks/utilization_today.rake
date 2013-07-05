desc "Spit out a report on utilization for Daniel"
task :utilization_today => :environment do
  def puts_names_for(list)
    list.map(&:name).sort.each{|p| puts p}
  end

  staff = Person.currently_employed
  staff_size = staff.size

  overhead = Person.overhead.currently_employed
  overhead_size = overhead.size

  billable = Person.billable.currently_employed
  billable_size = billable.size

  unassignable = Person.unassignable_today
  unassignable_size = unassignable.size

  assignable = billable - unassignable
  assignable_size = assignable.size

  billing = Person.billing_today
  billing_size = billing.size

  non_billing = assignable - billing
  non_billing_size = non_billing.size

  utilization = sprintf "%.1f", (100.0 * billing_size) / assignable_size

  puts "Current staff count is #{staff_size} of which #{billable_size} are billable and #{overhead_size} are not"
  puts "Of the #{billable_size} billable, #{assignable_size} are assignable and  #{unassignable_size} are not"
  puts "Of the #{assignable_size} assignable employees, #{billing_size} are billing today"
  puts
  puts
  puts "Daily utilization is billing as a percentage of assignable"
  puts "That is, non-billable people and those out on vacation are omitted from the calculation"
  puts "For today, that is #{billing_size} / #{assignable_size} = #{utilization}%"
  puts
  puts
  puts
  puts "Non billable staff in T2 - #{overhead_size}"
  puts "--------------------------------------"
  puts_names_for overhead
  puts
  puts
  puts "Unassignable (vacation, etc.) - #{unassignable_size}"
  puts "----------------------------------------"
  puts_names_for unassignable
  puts
  puts
  puts "Working, but not billing - #{non_billing_size}"
  puts "--------------------------------"
  puts_names_for non_billing
  puts
  puts
  puts "Billing today - #{billing_size}"
  puts "---------------------"
  puts_names_for billing
end
