class AddNonBillableToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :non_billable, :text
  end
end
