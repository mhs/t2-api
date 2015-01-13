namespace :project do
  desc 'set default rates for all roles for all projects'
  task :set_default_rates => :environment do
    Project.where(billable: true).each do |project|
      project.set_default_rates
      project.save
    end
  end
end
