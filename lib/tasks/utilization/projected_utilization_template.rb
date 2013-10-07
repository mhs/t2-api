class ProjectedUtilizationTemplate
  def initialize(snapshots)
    @snapshots = snapshots
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/projected_utilization_template.erb')
erb = ERB.new(File.read(filename))
erb.def_method(ProjectedUtilizationTemplate, 'render()', filename)
