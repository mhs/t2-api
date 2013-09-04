class AddAllowanceToProjectOffices < ActiveRecord::Migration
  def change
    add_column :project_offices, :allowance, :integer
  end
end
