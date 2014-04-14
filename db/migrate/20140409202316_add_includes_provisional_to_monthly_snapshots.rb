class AddIncludesProvisionalToMonthlySnapshots < ActiveRecord::Migration
  def up
    add_column :monthly_snapshots, :includes_provisional, :boolean, default: false
    add_index :monthly_snapshots, [:snap_date, :office_id, :includes_provisional], name: :unique_monthly_snapshots_index, unique: true
  end

  def down
    remove_index :monthly_snapshots, name: :unique_monthly_snapshots_index
    remove_column :monthly_snapshots, :includes_provisional
  end
end
