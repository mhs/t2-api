class CreateOpportunityNotes < ActiveRecord::Migration
  def change
    create_table :opportunity_notes do |t|
      t.text :detail, null: false
      t.belongs_to :person, null: false
      t.timestamps
    end
  end
end
