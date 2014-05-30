class AddArchiveStateToProject < ActiveRecord::Migration
  def change
    add_column :projects, :archived, :boolean, null: false, default: false
    add_index :projects, :archived
  end
end
