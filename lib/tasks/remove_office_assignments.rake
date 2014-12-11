desc "remove the project office records relating to deleted offices"
task :remove_deleted_office_assignments => :environment do
  active_projects = Project.only_active
  active_project_offices = active_projects.flat_map(&:project_offices)

  active_project_offices.select{ |po| po.office && po.office.deleted }.map(&:delete)
end
