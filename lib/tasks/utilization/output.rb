module UtilizationOutput
  def puts_names_for(list)
    list.sort_by(&:name).each{|p| puts p.name}
  end

  def utilization_puts(x = '')
    puts x
  end
end
