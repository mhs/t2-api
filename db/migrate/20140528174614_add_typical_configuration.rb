class AddTypicalConfiguration < ActiveRecord::Migration
  def up
    # setting default to '' and null to false results in a default of {}
    #
    add_column :projects, :typical_allocation_percentages, :hstore, default: '', null: false
    add_column :projects, :typical_counts, :hstore, default: '', null: false
    change_column :projects, :rates, :hstore, default: '', null: false
    add_column :projects, :num_weeks_per_invoice, :integer
  end

  def down
    change_column :projects, :rates, :hstore
    remove_column :projects, :typical_counts
    remove_column :projects, :typical_allocation_percentages
    remove_column :projects, :num_weeks_per_invoice
  end
end
