task :setup => ["config/database.yml", "Procfile.dev"]

file "config/database.yml" => "config/database.yml.example" do |t|
  sh "cp #{t.prerequisites.first} #{t.name}"
end

file "Procfile.dev" => "Procfile.dev.example" do |t|
  sh "cp #{t.prerequisites.first} #{t.name}"
end
