require 'allocations_in_dates'

p AllocationsInDates

desc "UK vacation days taken this year"
task :ukvacation, [:date_to]  => :environment do |_, args|
  date =  Date.parse(args[:date_to]) if args[:date_to]
  date ||= Date.today
  year_start = date.beginning_of_year
  vacation = Project.where(name:"Vacation").first
  Office.where(name:"Edinburgh").each do |uk|
    uk.people.employed_on_date(date).each do |e|
      puts "#{e.name},#{AllocationsInDates.new(vacation, e).allocations_between(year_start, date)}"
    end
  end
end
