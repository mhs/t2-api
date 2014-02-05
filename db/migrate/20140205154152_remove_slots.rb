class RemoveSlots < ActiveRecord::Migration
  def up
    drop_table :slots
  end
end
