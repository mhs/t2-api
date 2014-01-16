class GlobalUtilizationTemplate
  def initialize(snapshot)
    @snapshot = snapshot
  end

  def staff_count
    @snapshot.staff_weights.size
  end

  def overhead_count
    @snapshot.staff_weights.select do |k, v|
      v < 100
    end.size
  end

  def billable_count
    @snapshot.staff_weights.select do |k, v|
      v > 0
    end.size
  end

  def assignable_count
    format(@snapshot.assignable_weights.total)
  end

  def unassignable_count
    format(@snapshot.unassignable_weights.total)
  end

  def billing_count
    format(@snapshot.billing_weights.total)
  end

  def format(n)
    "%.2f" % (n / 100.0)
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/global_utilization_template.erb')
erb = ERB.new(File.read(filename))
erb.def_method(GlobalUtilizationTemplate, 'render()', filename)
