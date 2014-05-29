class AddSellingOfficeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :selling_office_id, :integer
    add_index :projects, :selling_office_id
  end
end
