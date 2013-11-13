class AddClassesToApplications < ActiveRecord::Migration
  def change
    add_column :t2_applications, :classes, :string
  end
end
