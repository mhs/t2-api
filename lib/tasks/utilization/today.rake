require File.expand_path(File.dirname(__FILE__) + '/output')

namespace :utilization do
  desc "Spit out a report on utilization for Daniel"
  task "today" => :environment do

    include UtilizationOutput

    snapshot = Snapshot.today!
    overhead_size     = snapshot.overhead.size
    billable_size     = snapshot.billable.size
    unassignable_size = snapshot.unassignable.size
    assignable_size   = snapshot.assignable.size
    billing_size      = snapshot.billing.size

    utilization_puts "Current staff count is #{snapshot.staff_ids.size} of which #{billable_size} are billable and #{overhead_size} are not"
    utilization_puts "Of the #{billable_size} billable, #{assignable_size} are assignable and  #{unassignable_size} are not"
    utilization_puts "Of the #{assignable_size} assignable employees, #{billing_size} are billing today"
    utilization_puts
    utilization_puts
    utilization_puts "Daily utilization is billing as a percentage of assignable"
    utilization_puts "That is, non-billable people and those out on vacation are omitted from the calculation"
    utilization_puts "For today, that is #{billing_size} / #{assignable_size} = #{snapshot.utilization}%"
    utilization_puts
    utilization_puts
    utilization_puts
    utilization_puts "Non billable staff in T2 - #{overhead_size}"
    utilization_puts "--------------------------------------"
    puts_names_for snapshot.overhead
    utilization_puts
    utilization_puts
    utilization_puts "Unassignable (vacation, etc.) - #{unassignable_size}"
    utilization_puts "----------------------------------------"
    puts_names_for snapshot.unassignable
    utilization_puts
    utilization_puts
    utilization_puts "Working, but not billing - #{snapshot.non_billing.size}"
    utilization_puts "--------------------------------"
    puts_names_for snapshot.non_billing
    utilization_puts
    utilization_puts
    utilization_puts "Billing today - #{billing_size}"
    utilization_puts "---------------------"
    puts_names_for snapshot.billing
  end
end
