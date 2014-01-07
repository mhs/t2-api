desc 'Report useful for entering booked revenue'
task :booked_revenue => :environment do
  usage = "rake booked_revenue START='2014-1-1' END='2014-1-31'"
  start_date = if ENV['START'].present?
                 Date.parse(ENV['START'])
               else
                 puts usage
                 exit
               end
  end_date = if ENV['END'].present?
                 Date.parse(ENV['END'])
               else
                 puts usage
                 exit
               end

  revenue_range = (start_date..end_date).reject{|d| d.saturday? || d.sunday?}

  pto_days_in_range = Hash.new{|h,k| h[k] = []}
  Allocation.joins(:project).where("allocations.end_date >= ?",start_date).where("allocations.start_date <= ?",end_date).where(:projects => { vacation: true }).each do |a|
    allocation_days = (a.start_date..a.end_date).reject{|d| d.saturday? || d.sunday?}
    pto_days_in_range[a.person_id].concat(revenue_range & allocation_days)
  end

  Project.where(vacation: false).order(:name).all.each do |project|
    days_allocated = Hash.new{|h,k| h[k] = 0}
    project.allocations.where("end_date >= ?",start_date).where("start_date <= ?",end_date).each do |a|
      allocation_days = (a.start_date..a.end_date).reject{|d| d.saturday? || d.sunday?}.reject{|d| pto_days_in_range[a.person_id].include?(d)}
      days_allocated[a.person_id] += (revenue_range & allocation_days).size
    end

    next if days_allocated.empty?
    puts project.name
    puts "-----------------------"
    days_allocated.each {|p,count| puts "#{Person.find(p).name} - #{count}"}
    puts "\n\n"
  end
end
