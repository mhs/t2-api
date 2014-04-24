class AddInvestmentFridaysToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :investment_fridays, :boolean, default: false
  end
end
