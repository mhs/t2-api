class ChangeMonthlySnapshotDaysToDecimal < ActiveRecord::Migration
  def up
    change_column :monthly_snapshots, :assignable_days, :decimal, scale: 2, precision: 6
    change_column :monthly_snapshots, :billing_days, :decimal, scale: 2, precision: 6
  end

  def down
    change_column :monthly_snapshots, :assignable_days, :integer
    change_column :monthly_snapshots, :billing_days, :integer
  end
end
