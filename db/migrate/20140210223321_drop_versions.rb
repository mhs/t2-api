class DropVersions < ActiveRecord::Migration
  def down
    drop_table :versions
  end
end
