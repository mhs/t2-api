class AddTimestampsToOpportunity < ActiveRecord::Migration
  def change
    add_column :opportunities, :created_at, :datetime
    add_column :opportunities, :updated_at, :datetime
  end
end
