class AddVoluntaryTerminationToPeople < ActiveRecord::Migration
  def change
    add_column :people, :voluntary_termination, :boolean, default: true
  end
end
