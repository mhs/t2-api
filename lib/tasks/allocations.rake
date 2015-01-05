namespace :allocation do
  desc 'sets likelihood for provisional allocations'
  task :set_likelihood => :environment do
    Allocation.where(provisional: true).each{ |a| a.update_attribute :likelihood, '90% Likely' }
    Allocation.where(provisional: false).each{ |a| a.update_attribute :likelihood, '100% Booked' }

    RevenueItem.where(provisional: true, likelihood: nil).where.not(allocation_id: nil).each{ |a| a.update_column :likelihood, '90% Likely' }
    RevenueItem.where(provisional: false, likelihood: nil).where.not(allocation_id: nil).each{ |a| a.update_column :likelihood, '100% Booked' }
  end
end
