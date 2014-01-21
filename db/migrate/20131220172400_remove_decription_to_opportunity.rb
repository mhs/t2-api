class RemoveDecriptionToOpportunity < ActiveRecord::Migration
  def up
    remove_column :opportunity_notes, :description
    add_column :opportunities, :description, :text
  end

  def down
    add_column :opportunity_notes, :description, :text
    remove_column :opportunity, :description
  end
end
