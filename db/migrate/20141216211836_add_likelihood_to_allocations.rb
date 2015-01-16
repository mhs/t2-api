class AddLikelihoodToAllocations < ActiveRecord::Migration
  def change
    add_column :allocations, :likelihood, :string
  end
end
