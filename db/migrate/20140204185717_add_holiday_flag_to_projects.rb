class AddHolidayFlagToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :holiday, :boolean, :default => false, :null => false
    proj = Project.where(:name => "Company Holiday").first
    if proj
      proj.update_attribute(:holiday, true)
    end
  end

  def down
    remove_column :projects, :holiday
  end
end
