class OfficeUtilizationTemplate
  def initialize(snapshots)
    @snapshots = snapshots.sort_by {|s| s.office.name}
  end

  def lj(string, char_count)
    string.ljust(char_count, ' ')
  end

  def format(n)
    "%.2f" % (n / 100.0)
  end

  def billing(snapshot)
    lj format(snapshot.billing_weights.total), 5
  end

  def office_name(snapshot)
    lj snapshot.office.name, 20
  end

  def billing_fraction(snapshot)
    lj format(snapshot.assignable_weights.total), 8
  end

  def assignable(snapshot)
    format(snapshot.assignable_weights.total)
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/office_utilization_template.erb')
erb = ERB.new(File.read(filename),0,'>')
erb.def_method(OfficeUtilizationTemplate, 'render()', filename)
