require File.expand_path(File.dirname(__FILE__) + '/../../utilization_helper')

namespace :utilization do
  desc "Spit out a report on utilization for Daniel along Three Weeks in the Future global and per-office"
  task :three_weeks => :environment do

    include UtilizationHelper

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
