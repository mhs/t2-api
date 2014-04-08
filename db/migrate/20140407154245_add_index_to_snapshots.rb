class AddIndexToSnapshots < ActiveRecord::Migration
  def change
    add_index :snapshots, [:snap_date, :office_id], unique: true
  end
end
