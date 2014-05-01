class ChangeCreatedByNameInAllocations < ActiveRecord::Migration
  def change
    rename_column :allocations, :created_by_id, :creator_id
  end
end
