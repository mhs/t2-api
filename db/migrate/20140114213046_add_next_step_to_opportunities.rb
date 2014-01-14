class AddNextStepToOpportunities < ActiveRecord::Migration
  def up
    add_column :opportunities, :next_step, :string
  end

  def down
    remove_column :opportunities, :next_step
  end
end
