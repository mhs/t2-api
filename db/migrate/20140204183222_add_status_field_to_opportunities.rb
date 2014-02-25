class AddStatusFieldToOpportunities < ActiveRecord::Migration
  def change
    add_column :opportunities, :status, :string, default: nil
  end
end
