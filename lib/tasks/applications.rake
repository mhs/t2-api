namespace :applications do

  desc 'Seeds the T2 applications'
  task :seed => :environment do
    T2Applications.delete_all
    applications_attributes = [
      {url: "http://t2-allocation.herokuapp.com",  icon: "c", title: "Allocations"},
      {url: "http://t2-utilization.herokuapp.com", icon: "h", title: "Utilization"},
      {url: "http://brockman.herokuapp.com",       icon: "b", title: "Pipeline"},
      {url: "http://t2-pto.herokuapp.com",         icon: "p", title: "PTO"}
    ]
    applications_attributes.each_with_index do |attrs, index|
      T2Applications.create(attrs.merge(position: index))
    end
  end
end
