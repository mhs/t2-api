class RemoveAllowances < ActiveRecord::Migration
  def change
    remove_column :project_offices, :allowance
    drop_table :project_allowances
  end
end
