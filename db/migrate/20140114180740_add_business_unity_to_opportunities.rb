class AddBusinessUnityToOpportunities < ActiveRecord::Migration
  def up
    add_column :opportunities, :office_id, :integer
  end

  def down
    remove_column :opportunities, :office_id
  end
end
