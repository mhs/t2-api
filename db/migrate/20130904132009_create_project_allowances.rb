class CreateProjectAllowances < ActiveRecord::Migration
  def change
    create_table :project_allowances do |t|
      t.integer :hours
      t.references :project
      t.references :person
    end

    add_index :project_allowances, :project_id
    add_index :project_allowances, :person_id
  end
end
