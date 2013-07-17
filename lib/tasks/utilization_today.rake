desc "Spit out a report on utilization for Daniel"
task :utilization_today => :environment do
  def puts_names_for(list)
    list.sort.each{|p| puts p}
  end

  snapshot = Hashie::Mash.new(Snapshot.today!.utilization.first)

  staff = snapshot.staff
  staff_size = staff.size

  overhead = snapshot.overhead
  overhead_size = overhead.size

  billable = snapshot.billable
  billable_size = billable.size

  unassignable = snapshot.unassignable
  unassignable_size = unassignable.size

  assignable = snapshot.assignable
  assignable_size = assignable.size

  billing = snapshot.billing
  billing_size = billing.size

  non_billing = assignable - billing
  non_billing_size = non_billing.size

  utilization = snapshot.utilization

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
