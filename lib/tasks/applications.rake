namespace :applications do

  desc 'Seeds the T2 applications'
  task :seed => :environment do
    T2Application.delete_all
    applications_attributes = [
      {url: "http://t2-allocation.herokuapp.com",       icon: "c", title: "Allocations"},
      {url: "http://t2-utilization.herokuapp.com",      icon: "h", title: "Utilization"},
      {url: "http://brockman.herokuapp.com",            icon: "b", title: "Pipeline"},
      {url: "http://t2-pto.herokuapp.com",              icon: "p", title: "PTO"},
      {url: "http://t2-user-preferences.herokuapp.com", icon: "s", title: "Settings"}
    ]
    applications_attributes.each_with_index do |attrs, index|
      T2Application.create(attrs.merge(position: index))
    end
  end

  desc 'Set the default T2 application for everyone'
  task :set_default_for_all => :environment do
    util = T2Application.where(title: 'Utilization').first
    User.find_each { |u| u.t2_application_id = util.id ; u.save }
  end
end
