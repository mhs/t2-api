class MakeProjectsSti < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string
    add_index :projects, :type

    Project.reset_column_information
    Project.find_each do |project|
      project.type = "StandardProject"
      project.save!
    end
  end
end
