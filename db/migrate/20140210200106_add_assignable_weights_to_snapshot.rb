class AddAssignableWeightsToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :assignable_weights, :text
  end
end
