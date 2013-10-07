require File.expand_path(File.dirname(__FILE__) + '/utilization_helper.rb')
require File.expand_path(File.dirname(__FILE__) + '/global_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/utilization_body_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/office_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/projected_utilization_template.rb')

namespace :utilization do
  desc "Spit out a report on utilization for Daniel"
  task "today" => :environment do

    include UtilizationHelper

    # Global Utilization
    today_snapshot = Snapshot.today!
    puts_if_no_test GlobalUtilizationTemplate.new(today_snapshot).render()

    # Per Office Utilization
    snapshots = []

    excluded_offices = ["", "Dublin", "Headquarters", "Archived"]

    offices = Office.all.reject do |office|
      snapshots << Snapshot.on_date!(Date.today, office) unless excluded_offices.include?(office.name)
    end

    puts_if_no_test OfficeUtilizationTemplate.new(snapshots).render()

    # Global 3 weeks utilization forecast
    projection_snapshots = []
    with_week_days 21 do |date|
      projection_snapshots << Snapshot.on_date!(date)
    end

    puts_if_no_test ProjectedUtilizationTemplate.new(projection_snapshots).render()

    # Body that includes actual people list
    puts_if_no_test UtilizationBodyTemplate.new(today_snapshot).render()
  end
end
