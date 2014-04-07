class AddProvisionalToProjectsAndAllocations < ActiveRecord::Migration
  def change
    add_column :projects, :provisional, :boolean, default: false
    add_column :allocations, :provisional, :boolean, default: false
  end
end
