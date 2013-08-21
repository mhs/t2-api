class AddT2ApplicationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :t2_application_id, :integer
  end
end
