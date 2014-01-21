class AddDescriptionToOpportunity < ActiveRecord::Migration
  def up
    add_column :opportunity_notes, :description, :text
  end

  def down
    remove_column :opportunity_notes, :description
  end
end
