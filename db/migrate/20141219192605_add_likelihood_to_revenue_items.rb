class AddLikelihoodToRevenueItems < ActiveRecord::Migration
  def change
    add_column :revenue_items, :likelihood, :string
  end
end
