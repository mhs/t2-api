class RenameIncludesProvisionalFlagOnSnapshotTables < ActiveRecord::Migration
  def change
    rename_column :snapshots, :includes_provisional, :includes_speculative
    rename_column :monthly_snapshots, :includes_provisional, :includes_speculative
  end
end
