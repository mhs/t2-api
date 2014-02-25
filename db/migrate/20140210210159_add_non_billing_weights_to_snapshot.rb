class AddNonBillingWeightsToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :non_billing_weights, :text
  end
end
