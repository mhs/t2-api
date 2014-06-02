class AddBillableDaysToMonthlySnapshot < ActiveRecord::Migration
  def change
    add_column :monthly_snapshots, :billable_days, :decimal, precision: 6, scale: 2, default: 0.0
    add_column :monthly_snapshots, :gross_utilization, :decimal, precision: 6, scale: 2, default: 0.0
  end
end
