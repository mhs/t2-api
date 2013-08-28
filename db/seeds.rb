T2Application.delete_all
applications_attributes = [
  {url: "http://localhost:9000",  icon: "c", title: "Allocations"},
  {url: "http://localhost:7000", icon: "g", title: "Utilization"},
  {url: "http://brockman.herokuapp.com",       icon: "b", title: "Pipeline"},
  {url: "http://localhost:8000",         icon: "p", title: "PTO"}
]
applications_attributes.each_with_index do |attrs, index|
  T2Application.create(attrs.merge(position: index))
end
