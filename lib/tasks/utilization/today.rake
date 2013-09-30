require File.expand_path(File.dirname(__FILE__) + '/global_utilization_template.rb')
require File.expand_path(File.dirname(__FILE__) + '/office_utilization_template.rb')

namespace :utilization do
  desc "Spit out a report on utilization for Daniel"
  task "today" => :environment do

    # FIXME: Output should not be displayed under Test env.
    # There should be a beetter way to do this :)
    def puts_if_no_test(content)
      unless Rails.env.test?
        puts content
      end
    end

    # Global Utilization
    puts_if_no_test GlobalUtilizationTemplate.new(Snapshot.today!).render()

    # Per Office Utilization
    snapshots = []

    excluded_offices = ["", "Dublin", "Headquarters", "Archived"]

    offices = Office.all.reject do |office|
      snapshots << Snapshot.on_date!(Date.today, office) unless excluded_offices.include?(office.name)
    end

    puts_if_no_test OfficeUtilizationTemplate.new(snapshots).render()
  end
end
