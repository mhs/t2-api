namespace :revenue do
  desc "Recalculate revenue items for the future"
  task :daily_recalculate => :environment do
    start_date = Date.today.beginning_of_month
    end_date = Date.today + 6.months
    Person.includes(:allocations => :project).employed_between(start_date, end_date).find_each do |person|
      person.revenue_items_for(start_date, end_date)
    end
  end
end
