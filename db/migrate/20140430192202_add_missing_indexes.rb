class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :allocations, :created_by_id
    add_index :users, :office_id
    add_index :users, :t2_application_id
    add_index :taggings, [:tagger_id, :tagger_type]
    add_index :office_holidays, :holiday_id
    add_index :office_holidays, :office_id
    add_index :people, :user_id
  end
end
