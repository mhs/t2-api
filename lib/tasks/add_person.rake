namespace :person do
  person_add_usage = "`[NAME=\"John Smith\" | EMAIL=johnny.smith@neo.com] [OFFICE=\"San Francisco\"] rake person:add`"
  desc "Add a person (and user) #{person_add_usage}"
  task :add => :environment do |t|
    office = ENV['OFFICE'] ? Office.find_by_name(ENV['OFFICE']) : Office.all.sample
    name   = ENV['NAME']
    email  = ENV['EMAIL']

    name_from_email = /^([a-z]+)[^a-z]([a-z]*)\@.*$/i
    if name.nil? && email.present? && n = email.match(name_from_email)
      name = [n[1], n[2]].map(&:capitalize).join(' ')
    elsif email.nil? && name.present?
      email = "#{name.gsub(/'/, '').downcase.split(/\s+/).join('.')}@neo.com"
    elsif name.nil? && email.nil?
      raise "\nPlease provide a name, an email address or both, e.g:\n\n#{person_add_usage}\n\n"
    end

    person = FactoryGirl.create :person,
      name: name,
      email: email,
      office: office

    puts "#{person.name} :: #{person.email} :: #{person.office.name}"
  end
end
