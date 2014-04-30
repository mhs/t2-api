namespace :revenue do
  desc "create revenue items for every allocation in the database"
  task :all => :environment do
    start_date = Allocation.joins(:person).order(start_date: :asc).first.start_date
    end_date = Allocation.joins(:person).order(end_date: :desc).first.end_date
    $stderr.puts "Calculating for #{start_date} to #{end_date}"
    $stderr.flush
    Person.includes(:allocations => :project).find_each do |person|
      $stderr.print "#{person.name}: "
      $stderr.flush
      items = person.revenue_items_for(start_date, end_date)
      $stderr.puts items.size
      $stderr.flush
    end
  end
end
