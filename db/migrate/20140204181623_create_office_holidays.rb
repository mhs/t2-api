class CreateOfficeHolidays < ActiveRecord::Migration
  def change
    create_table :office_holidays do |t|
      t.references :office
      t.references :holiday
    end
  end
end
