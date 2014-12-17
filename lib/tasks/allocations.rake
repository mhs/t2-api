namespace :allocation do
  desc 'sets likelihood for provisional allocations'
  task :set_likelihood => :environment do
    Allocation.provisional.each{ |a| a.update_attribute :likelihood, '90% Likely' }
  end
end
