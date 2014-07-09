desc "Dump stats on PTO usage"
task :pto => :environment do
  puts "Person,Office,Holiday Days,Vacation Days,Sick Days,Conference Days,On Leave Days,Total Days"
  Office.order(:name).each do |office|
    office.people.order(:name).employed_on_date(Date.today).each do |person|
      pto = person.pto_this_year
      total = pto['Company Holiday'].size + pto['Vacation'].size + pto['Sick'].size + pto['Conference - Unbillable'].size + pto['On Leave'].size
      puts "#{person.name},#{office.name},#{pto['Company Holiday'].size},#{pto['Vacation'].size},#{pto['Sick'].size},#{pto['Conference - Unbillable'].size},#{pto['On Leave'].size},#{total}"
    end
  end
end
