class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.text :utilization
      t.date :snap_date

      t.timestamps
    end
  end
end
