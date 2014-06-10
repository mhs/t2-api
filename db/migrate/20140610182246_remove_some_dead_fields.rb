class RemoveSomeDeadFields < ActiveRecord::Migration
  def up
    remove_column :projects, :client_principal_id
    remove_column :projects, :slug
  end

  def down
    add_column :projects, :slug, :string
    add_column :projects, :client_principal_id, :integer
  end
end
