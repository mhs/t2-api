class AddUserAssociationToAllocation < ActiveRecord::Migration
  def change
    add_column :allocations, :created_by_id, :integer
  end
end
