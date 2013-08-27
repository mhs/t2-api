namespace :applications do

  desc 'Seeds the T2 applications'
  task :seed => :environment do
    T2Application.delete_all
    applications_attributes = [
      {url: "http://t2-allocation.herokuapp.com",  icon: "c", title: "Allocations"},
      {url: "http://t2-utilization.herokuapp.com", icon: "h", title: "Utilization"},
      {url: "http://brockman.herokuapp.com",       icon: "b", title: "Pipeline"},
      {url: "http://t2-pto.herokuapp.com",         icon: "p", title: "PTO"}
    ]
    applications_attributes.each_with_index do |attrs, index|
      T2Application.create(attrs.merge(position: index))
    end
  end

  desc 'Seeds the T2 applications'
  task :dev_seed => :environment do
    T2Application.delete_all
    applications_attributes = [
      {url: "http://localhost:9000",  icon: "c", title: "Allocations"},
      {url: "http://localhost:7000", icon: "h", title: "Utilization"},
      {url: "http://brockman.herokuapp.com",       icon: "b", title: "Pipeline"},
      {url: "http://localhost:8000",         icon: "p", title: "PTO"}
    ]
    applications_attributes.each_with_index do |attrs, index|
      T2Application.create(attrs.merge(position: index))
    end
  end
end
