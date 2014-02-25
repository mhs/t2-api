class AddDefaultsToMonthlySnapshot < ActiveRecord::Migration
  def change
    change_column :monthly_snapshots, :assignable_days, :integer, default: 0
    change_column :monthly_snapshots, :billing_days, :integer, default: 0
  end
end
