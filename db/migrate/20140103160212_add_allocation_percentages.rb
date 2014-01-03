class AddAllocationPercentages < ActiveRecord::Migration
  def change
    add_column :people, :percent_billable, :integer
    add_column :allocations, :percent_allocated, :integer
  end
end
