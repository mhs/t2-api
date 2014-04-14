class AddIncludesProvisionalToSnapshots < ActiveRecord::Migration
  def up
    add_column :snapshots, :includes_provisional, :boolean, default: false
    remove_index :snapshots, column: [:snap_date, :office_id], unique: true
    add_index :snapshots, [:snap_date, :office_id, :includes_provisional], name: :unique_snapshots_index, unique: true
  end

  def down
    remove_index :snapshots, name: :unique_snapshots_index
    add_index :snapshots, [:snap_date, :office_id], unique: true
    remove_column :snapshots, :includes_provisional
  end
end
