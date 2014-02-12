class ChangeWeightColumnNamesOnSnapshots < ActiveRecord::Migration
  def change
    rename_column :snapshots, :staff_weights,         :staff
    rename_column :snapshots, :unassignable_weights,  :unassignable
    rename_column :snapshots, :billing_weights,       :billing
    rename_column :snapshots, :assignable_weights,    :assignable
    rename_column :snapshots, :non_billing_weights,   :non_billing
  end
end
