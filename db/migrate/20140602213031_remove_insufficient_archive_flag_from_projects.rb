class RemoveInsufficientArchiveFlagFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :archived
  end
end
