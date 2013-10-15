class AddFieldsToPersonProfile < ActiveRecord::Migration
  def change
    add_column :people, :github, :string
    add_column :people, :twitter, :string
    add_column :people, :website, :string
    add_column :people, :title, :string
    add_column :people, :bio, :text
  end
end
