namespace :project do
  desc 'set default rates for all roles for all projects'
  task :set_default_rates => :environment do
    Project.where(billable: true).each(&:set_default_rates)
  end
end
