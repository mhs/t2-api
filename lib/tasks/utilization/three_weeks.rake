require File.expand_path(File.dirname(__FILE__) + '/output')

def with_week_days(&block)
  date_range = ((Date.today)..(21.days.from_now.to_date))

  date_range.to_a.each do |date|
    unless date.saturday? || date.sunday?
      yield date
    end
  end
end

namespace :utilization do
  desc "Spit out a report on utilization for Daniel along Three Weeks in the Future global and per-office"
  task :three_weeks => :environment do

    include UtilizationOutput

    with_week_days do |date|
      Snapshot.on_date!(date)
    end

    with_week_days do |date|
      Office.all.each do |office|
        Snapshot.on_date!(date, office.id)
      end
    end
  end
end
