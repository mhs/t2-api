require 'yaml'

data = YAML.load_file "/vagrant/config/database.yml"
data["development"]["username"] = "vagrant"
data["development"]["password"] = "vagrant"
File.open("/vagrant/config/database.yml", 'w') { |f| YAML.dump(data, f) }
