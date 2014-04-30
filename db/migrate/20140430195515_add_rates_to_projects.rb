class AddRatesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :rates, :hstore
  end
end
