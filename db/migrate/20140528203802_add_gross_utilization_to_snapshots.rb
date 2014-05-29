class AddGrossUtilizationToSnapshots < ActiveRecord::Migration
  def change
    # NOTE: not sure why the utilization column is a string, but make this one the same
    add_column :snapshots, :gross_utilization, :string
  end
end
