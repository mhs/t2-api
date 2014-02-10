class RemoveOpportunityNotes < ActiveRecord::Migration
  def up
    drop_table :opportunity_notes
  end
end
