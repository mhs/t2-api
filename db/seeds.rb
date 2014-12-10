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

# create the offices
[ "Columbus", "New York", "San Francisco", "Singapore", "Headquarters"
].each do |name|
  Office.where(name: name, slug: name.parameterize).first_or_create
end

regular_rates = {
  'Developer'       => 5000,
  'Designer'        => 5000,
  'Principal'       => 5000,
  'Product Manager' => 5000
}
roles = regular_rates.keys

# Projects with a single office
5.times do
  office_ids = Office.all.sample(1).map &:id
  FactoryGirl.create :project,
    office_ids: office_ids,
    rates: regular_rates,
    selling_office_id: office_ids.first,
    start_date: (rand * 100).to_i.days.ago,
    end_date: (rand * 100).to_i.days.from_now
end

# Projects with multiple offices
5.times do
  office_ids = Office.all.sample(2).map &:id
  FactoryGirl.create :project,
    office_ids: office_ids,
    rates: regular_rates,
    selling_office_id: office_ids.first,
    start_date: (rand * 100).to_i.days.ago,
    end_date: (rand * 100).to_i.days.from_now
end

# A few projects have investment friday
Project.where(vacation: false).sample(3).each{ |p| p.update_attribute :investment_fridays, true }

# A few projects are provisional
Project.where(vacation: false).sample(3).each{ |p| p.update_attribute :provisional, true }

# Vacation style projects
vacation_rates = {
  'Developer'       => 0,
  'Designer'        => 0,
  'Principal'       => 0,
  'Product Manager' => 0 }

[ { name: 'Vacation',                binding: true,  vacation: true                },
  { name: 'Company Holiday',         binding: true,  vacation: true, holiday: true },
  { name: 'Conference - Unbillable', binding: true,  vacation: true                },
  { name: 'Sick',                    binding: true,  vacation: true                },
  { name: 'On Leave',                binding: false, vacation: true                }
].each do |project|
  unless Project.find_by_name(project[:name])
    FactoryGirl.create :project, project.merge( office_ids: Office.all.map(&:id), rates: vacation_rates )
  end
end

# People
Office.all.each do |office|
  5.times do
    FactoryGirl.create :person,
      role: roles.sample,
      office: office
  end
end

# How about some allocations!
people = Person.all
Project.where(vacation: false).each do |project|
  Person.all.select{|p| p.allocations.size < 4}.sample((rand * 10).to_i).each do |person|
    days_in_project = project.end_date.mjd - project.start_date.mjd
    dates = []
    2.times { dates << project.start_date + rand(days_in_project).days }
    FactoryGirl.create :allocation,
      person: person,
      project: project,
      provisional: (person.allocations.size > 2),
      percent_allocated: 50,
      start_date: dates.min,
      end_date: dates.max
  end
end
