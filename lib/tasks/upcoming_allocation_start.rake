desc "Find the allocations that start less than 2 days from now"
task :allocation_start_date => :environment do
  speculative_allocations_within_2_days = Allocation.starting_soon.speculative
  recipients = speculative_allocations_within_2_days.map {|a| a.creator.email}.uniq

  recipients.each {|email| UserMailer.allocation_upcoming_email(email).deliver}
end
