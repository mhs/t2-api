class CreateOpportunity < ActiveRecord::Migration
  def change
    create_table :opportunities do |t|
      t.string :title
      t.string :stage
      t.string :confidence, default: 'warm'
      t.decimal :amount, default: 0
      t.datetime :expected_date_close
      t.belongs_to :person, null: false
      t.belongs_to :company
    end
  end
end
