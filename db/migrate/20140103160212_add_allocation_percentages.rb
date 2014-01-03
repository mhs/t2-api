class AddAllocationPercentages < ActiveRecord::Migration
  def up
    add_column :allocations, :percent_allocated, :integer

    add_column :people, :percent_billable, :integer, null: false, default: 100

    Person.reset_column_information

    Person.all.each do |person|
      person.percent_billable = person.unsellable ? 0 : 100
      person.save
    end

    remove_column :people, :unsellable
  end

  def down
    remove_column :allocations, :percent_allocated

    add_column :people, :unsellable, null: false, default: false, index: true

    Person.reset_column_information

    Person.all.each do |person|
      if person.percent_billable > 0
        person.unsellable = false
      else
        person.unsellable = true
      end
      person.save
    end

  end
end
