desc "Change project names so it obscures who we are looking for"
task :obscure_projects => :environment do
  Project.all.each do |project|
    project.name = "Project #{project.id}"
    project.save!
  end
end
