class SetAllocationDefaultPercentage < ActiveRecord::Migration
  def up
    change_column :allocations, :percent_allocated, :integer, null: false, default: 100
  end

  def down
    change_column :allocations, :percent_allocated, :integer
  end
end
