class RemoveOpportunities < ActiveRecord::Migration
  def up
    drop_table :opportunities
  end
end
