# encoding: utf-8
T2Application.delete_all
applications_attributes = [
  {url: "http://localhost:9000", icon: "📊", title: "Allocations", classes: "allocations", position: 0},
  {url: "http://localhost:9001", icon: "", title: "Projects", position: 1},
  {url: "http://localhost:7000", icon: "📈", title: "Utilization", position: 2},
  {url: "http://localhost:9999", icon: "👤", title: "Neons", position: 3}
]
applications_attributes.each_with_index do |attrs, index|
  T2Application.create(attrs.merge(position: index))
end

OFFICES = ["Columbus", "New York", "San Francisco", "Singapore", "Headquarters"]

OFFICES.each do |name|
  Office.where(name: name, slug: name.parameterize).first_or_create
end


RATES = {
  'Developer' => 5000,
  'Designer' => 5000,
  'Principal' => 5000,
  'Product Manager' => 5000
}
# Projects with a single office

5.times do
  FactoryGirl.create(:project,
    offices: Office.all.sample(1),
    rates: RATES
  )
end

# Projects with multiple offices

5.times do
  FactoryGirl.create(:project,
    offices: Office.all.sample(2),
    rates: RATES
  )
end

# One project has investment friday
Project.first.update_attribute(:investment_fridays, false)

Project.where(name: 'Vacation', binding: true, vacation: true).first_or_create
Project.where(name: 'Company Holiday', holiday: true, binding: true, vacation: true).first_or_create
Project.where(name: 'Conference - Unbillable', binding: true, vacation: true).first_or_create
Project.where(name: 'Sick', binding: true, vacation: true).first_or_create
Project.where(name: 'On Leave', binding: false, vacation: true).first_or_create
