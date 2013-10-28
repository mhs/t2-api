class CreateMonthlySnapshots < ActiveRecord::Migration
  def change
    create_table :monthly_snapshots do |t|
      t.integer :office_id
      t.date :snap_date
      t.integer :assignable_days
      t.integer :billing_days
      t.timestamps
    end

    add_index :monthly_snapshots, :snap_date
    add_index :monthly_snapshots, :office_id
  end
end
