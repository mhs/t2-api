# encoding: utf-8
T2Application.delete_all
applications_attributes = [
  {url: "http://localhost:9000",            icon: "📊", title: "Allocations", classes: "allocations"},
  {url: "http://localhost:7000",            icon: "📈", title: "Utilization"},
  {url: "http://localhost:9999",            icon: "👤", title: "Neons"},
]
applications_attributes.each_with_index do |attrs, index|
  T2Application.create(attrs.merge(position: index))
end
