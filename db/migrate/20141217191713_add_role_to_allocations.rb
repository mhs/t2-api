class AddRoleToAllocations < ActiveRecord::Migration
  def change
    add_column :allocations, :role, :string
  end
end
