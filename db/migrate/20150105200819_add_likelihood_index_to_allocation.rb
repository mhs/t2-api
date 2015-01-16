class AddLikelihoodIndexToAllocation < ActiveRecord::Migration
  def change
    add_index :allocations, :likelihood
  end
end
