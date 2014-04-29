class AddBillableTrueDefaultValueToProjects < ActiveRecord::Migration
  def change
    change_column :projects, :billable, :boolean, :default => true
  end
end
