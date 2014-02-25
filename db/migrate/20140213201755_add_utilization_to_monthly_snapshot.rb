class AddUtilizationToMonthlySnapshot < ActiveRecord::Migration
  def change
    add_column :monthly_snapshots, :utilization, :decimal, precision: 6, scale: 2, default: 0.0
  end
end
