class ReportTemplate
  attr_accessor :snapshots
  include DateRangeHelper

  def initialize(filename)
    file = File.join(File.expand_path(File.dirname(__FILE__)), filename)
    erb  = ERB.new(File.read(file), :thread_safe, '-')
    erb.def_method(self.class, 'render(snapshots)', file)
  end

  def person_rows(weighted_set, suppressed_percentage=100)
    weighted_set.sort_by{ |name, _| name }.map do |name, percent|
      percent == suppressed_percentage ? [name] : ["#{name} (#{percent}%)"]
    end
  end

  def monthly_snapshot_title(snapshot)
    date = snapshot.snap_date
    prefix = date.future? ? "Projected " : nil
    "#{prefix}Monthly Utilization Report: #{date.to_s(:short)} - #{date.end_of_month.to_s(:short)} #{date.year}"
  end

  def to_percent(n)
    "%.2f" % n
  end

  def display(output)
    unless Rails.env.test?
      puts output
      puts "\n\n"
    end
  end
end
