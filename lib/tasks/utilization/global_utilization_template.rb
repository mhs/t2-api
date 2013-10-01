class GlobalUtilizationTemplate
  def initialize(snapshot)
    @snapshot = snapshot
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/global_utilization_template.erb')
erb = ERB.new(File.read(filename))
erb.def_method(GlobalUtilizationTemplate, 'render()', filename)
