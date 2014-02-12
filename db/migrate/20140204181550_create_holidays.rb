class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end
end
