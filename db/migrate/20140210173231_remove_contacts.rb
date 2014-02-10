class RemoveContacts < ActiveRecord::Migration
  def up
    drop_table :contacts
  end
end
