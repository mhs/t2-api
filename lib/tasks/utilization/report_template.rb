class ReportTemplate
  attr_accessor :snapshots

  def initialize(filename)
    file = File.join(File.expand_path(File.dirname(__FILE__)), filename)
    erb  = ERB.new(File.read(file), :thread_safe, '-')
    erb.def_method(self.class, 'render(snapshots)', file)
  end

  def person_rows(weighted_set)
    weighted_set.sort_by{ |name, _| name }.map do |name, percent|
      percent == 100 ? name : "#{name} (#{percent}%)"
    end.join("\n")
  end
end
