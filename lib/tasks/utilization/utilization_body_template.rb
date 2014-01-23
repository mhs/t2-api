class UtilizationBodyTemplate
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

  def non_billing_count
    format(@snapshot.non_billing_weights.total)
  end

  def format(n)
    "%.2f" % (n / 100.0)
  end

  def names_for(weights)
    weights.keys.sort.map { |x| weights[x] == 100 ? x : "#{x} (#{weights[x]}%)" }.join("\n")
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/utilization_body_template.erb')
erb = ERB.new(File.read(filename))
erb.def_method(UtilizationBodyTemplate, 'render()', filename)
