class MakeBindingTrueOnAllocation < ActiveRecord::Migration
  def change
    change_column :allocations, :binding, :boolean, default: true, null: false
  end
end
