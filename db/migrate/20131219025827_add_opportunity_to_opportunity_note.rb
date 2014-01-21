class AddOpportunityToOpportunityNote < ActiveRecord::Migration
  def up
    add_column :opportunity_notes, :opportunity_id, :integer
  end

  def down
    remove_column :opportunity_notes, :opportunity_id
  end
end
