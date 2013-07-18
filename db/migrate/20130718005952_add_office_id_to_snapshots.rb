class AddOfficeIdToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :office_id, :integer
  end
end
