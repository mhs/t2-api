class RemoveCompanies < ActiveRecord::Migration
  def up
    drop_table :companies
  end
end
