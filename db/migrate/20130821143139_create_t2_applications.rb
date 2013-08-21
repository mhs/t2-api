class CreateT2Applications < ActiveRecord::Migration
  def change
    create_table :t2_applications do |t|
      t.string :url
      t.string :icon
      t.string :title
      t.integer :position

      t.timestamps
    end
  end
end
