class UtilizationBodyTemplate
  def initialize(snapshot)
    @snapshot = snapshot
  end

  def names_for(list)
    list.sort_by(&:name).map(&:name).join("\n")
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/utilization_body_template.erb')
erb = ERB.new(File.read(filename))
erb.def_method(UtilizationBodyTemplate, 'render()', filename)
