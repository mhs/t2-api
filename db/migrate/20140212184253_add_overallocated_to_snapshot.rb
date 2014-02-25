class AddOverallocatedToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :overallocated, :text
  end
end
