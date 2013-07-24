# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Date ranges
cincinnati_office = Office.create name: "Cincinnati", slug: "cincinnati"
columbus_office = Office.create name: "Columbus", slug: "columbus"
montevideo_office = Office.create name: "Montevideo", slug: "montevideo"

dave_person = Person.create name: "Dave Anderson", office: cincinnati_office, start_date: "2012-02-28", email: "dave@neo.com"
dan_person = Person.create name: "Dan Williams", office: cincinnati_office, start_date: "2012-03-11", email: "dan@neo.com"
lauren_person = Person.create name: "Lauren Woodrich", office: cincinnati_office, start_date: "2013-04-28", email: "lauren@neo.com"
mike_person = Person.create name: "Mike Doel", office: columbus_office, start_date: "2008-05-12", email: "mike.doel@neo.com"

nexia_home_project = Project.create name: "Nexia Home", billable: true, binding: true, slug: "nexia-home"
nexia_home_project.offices << cincinnati_office
t2_project = Project.create name: "T2", slug: "t2", client_principal: mike_person
t2_project.offices << cincinnati_office
t2_project.offices << columbus_office

slot_1 = Slot.create start_date: Date.today, end_date: 2.months.from_now, project: t2_project
slot_2 = Slot.create start_date: 1.month.from_now, end_date: 75.days.from_now, project: nexia_home_project

Allocation.create start_date: Date.today, end_date: 1.month.from_now, billable: true, binding: true, person: dave_person, project: t2_project
Allocation.create start_date: Date.today, end_date: 2.months.from_now, billable: true, binding: true, person: mike_person, project: t2_project
Allocation.create start_date: 1.month.from_now, end_date: 80.days.from_now, billable: true, binding: true, person: lauren_person, project: t2_project
Allocation.create start_date: 1.month.from_now, end_date: 60.days.from_now, billable: true, binding: true, slot: slot_2, person: dan_person, project: nexia_home_project