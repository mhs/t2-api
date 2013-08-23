namespace :person_tags do

  person_tags_add_usage = "`rake person_tags:add [ID=person_id | EMAIL=person_email | NAME=person_name] SKILLS=ios,android`"

  desc "Add skills to persons #{person_tags_add_usage}"
  task :add => :environment do |t|

    person = if ENV['ID'].present?
      Person.find(ENV['ID'])
    elsif ENV["NAME"].present?
      Person.find_by_name(ENV['NAME'])
    elsif ENV["EMAIL"].present?
      Person.find_by_email(ENV['EMAIL'])
    else
      puts "Usage: #{person_tags_add_usage}"
      exit
    end

    ENV['SKILLS'].split(',').each do |skill|
      person.skill_list.add(skill)
    end

    person.save!
    person.reload

    puts "#{person.name} :: #{person.skills.join(', ')}"
  end
end
