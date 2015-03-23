# encoding: utf-8
applications_attributes = [
  {url: "http://localhost:9000", icon: "📊", title: "Allocations", classes: "allocations", position: 0},
  {url: "http://localhost:9001", icon: "", title: "Projects", position: 1},
  {url: "http://localhost:7000", icon: "📈", title: "Utilization", position: 2},
  {url: "http://localhost:9999", icon: "👤", title: "Humans", position: 3}
]
applications_attributes.each_with_index do |attrs, index|
  T2Application.where(title: attrs[:title]).first_or_create! do |app|
    app.url = attrs[:url]
    app.icon = attrs[:icon]
    app.classes = attrs[:classes]
    app.position = index
  end
end

['Grand Rapids', 'Columbus'].each do |name|
  Office.where(name: name, slug: name.parameterize).first_or_create!
end

VACATION_RATES = {
  'Developer'       => 0,
  'Designer'        => 0,
  'Principal'       => 0,
  'Product Manager' => 0
}

MISC_PROJECTS = [
  { name: 'Vacation',                binding: true,  vacation: true                },
  { name: 'Company Holiday',         binding: true,  vacation: true, holiday: true },
  { name: 'Conference - Unbillable', binding: true,  vacation: true                },
  { name: 'Sick',                    binding: true,  vacation: true                },
]

MISC_PROJECTS.each do |project|
  Project.where(name: project[:name]).first_or_create! do |project|
    project.binding = project[:binding]
    project.vacation = project[:vacation]
    project.holiday = project[:holiday]
    project.office_ids = Office.pluck(:id)
    project.rates = VACATION_RATES
  end
end
