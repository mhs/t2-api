class OfficeUtilizationTemplate
  def initialize(snapshots)
    @snapshots = snapshots
  end
end

filename = File.expand_path(File.dirname(__FILE__) + '/office_utilization_template.erb')
erb = ERB.new(File.read(filename),0,'>')
erb.def_method(OfficeUtilizationTemplate, 'render()', filename)
