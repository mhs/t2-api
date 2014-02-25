class ChangeColumnTypesOnMonthlySnapshots < ActiveRecord::Migration
  def change
    change_column :monthly_snapshots, :assignable_days, :decimal, precision: 6, scale: 2, default: 0.0
    change_column :monthly_snapshots, :billing_days, :decimal, precision: 6, scale: 2, default: 0.0
  end
end
