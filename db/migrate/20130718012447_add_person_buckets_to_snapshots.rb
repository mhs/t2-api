class AddPersonBucketsToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :staff_ids, :text
    add_column :snapshots, :overhead_ids, :text
    add_column :snapshots, :billable_ids, :text
    add_column :snapshots, :unassignable_ids, :text
    add_column :snapshots, :assignable_ids, :text
    add_column :snapshots, :billing_ids, :text
    add_column :snapshots, :non_billing_ids, :text
  end
end
