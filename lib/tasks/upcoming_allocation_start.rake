desc "Find the allocations that start less than 2 days from now"
task :allocation_start_date => :environment do
  provisional_allocations_within_2_days = Allocation.starting_soon.provisional
  recipients = provisional_allocations_within_2_days.map {|a| a.creator.email}.uniq

  recipients.each {|email| UserMailer.allocation_upcoming_email(email).deliver}
end

