class AddBillableToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :billable, :text
  end
end
