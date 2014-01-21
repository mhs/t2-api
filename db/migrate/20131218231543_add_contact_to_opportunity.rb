class AddContactToOpportunity < ActiveRecord::Migration
  def up
    add_column :opportunities, :contact_id, :integer
  end

  def down
    remove_column :opportunities, :contact_id
  end
end
