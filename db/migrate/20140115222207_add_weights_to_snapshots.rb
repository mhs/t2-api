require 'weighted_set'

class AddWeightsToSnapshots < ActiveRecord::Migration
  def up
    add_column :snapshots, :staff_weights, :text
    add_column :snapshots, :unassignable_weights, :text
    add_column :snapshots, :billing_weights, :text

    # these are no longer in the Snapshot class
    Snapshot.class_eval do
      serialize :staff_ids
      serialize :overhead_ids
      serialize :billable_ids
      serialize :unassignable_ids
      serialize :assignable_ids
      serialize :billing_ids
      serialize :non_billing_ids
    end

    Snapshot.reset_column_information

    people_hash = Person.all.each_with_object({}) { |person, h| h[person.id] = person.name }
    people_unsellable = Person.all.each_with_object({}) { |person, h| h[person.id] = person.percent_billable == 0 }

    # migrate all the things
    Snapshot.find_each do |snapshot|
      snapshot.staff_weights = snapshot.staff_ids.each_with_object(WeightedSet.new) do |id, set|
        set[people_hash[id]] = people_unsellable[id] ? 0 : 100
      end
      snapshot.unassignable_weights = ids_to_weights(snapshot.unassignable_ids, people_hash)
      snapshot.billing_weights = ids_to_weights(snapshot.billing_ids, people_hash)
      snapshot.save!
    end

    remove_column :snapshots, :staff_ids
    remove_column :snapshots, :overhead_ids
    remove_column :snapshots, :billable_ids
    remove_column :snapshots, :unassignable_ids
    remove_column :snapshots, :assignable_ids
    remove_column :snapshots, :billing_ids
    remove_column :snapshots, :non_billing_ids
  end

  def down
    add_column :snapshots, :staff_ids, :text
    add_column :snapshots, :overhead_ids, :text
    add_column :snapshots, :billable_ids, :text
    add_column :snapshots, :unassignable_ids, :text
    add_column :snapshots, :assignable_ids, :text
    add_column :snapshots, :billing_ids, :text
    add_column :snapshots, :non_billing_ids, :text

    Snapshot.class_eval do
      serialize :staff_ids
      serialize :overhead_ids
      serialize :billable_ids
      serialize :unassignable_ids
      serialize :assignable_ids
      serialize :billing_ids
      serialize :non_billing_ids

      serialize :staff_weights, WeightedSet
      serialize :unassignable_weights, WeightedSet
      serialize :billing_weights, WeightedSet
    end

    Snapshot.reset_column_information

    people_names_hash = Person.all.each_with_object({}) { |person, h| h[person.name] = person.id }

    # migrate all the things
    Snapshot.find_each do |snapshot|
      snapshot.staff_ids = weights_to_ids(snapshot.staff_weights, people_names_hash)
      snapshot.overhead_ids = []
      snapshot.billable_ids = []
      snapshot.staff_weights.each_pair do |name, percent|
        if percent > 0
          snapshot.billable_ids << people_names_hash[name]
        else
          snapshot.overhead_ids << people_names_hash[name]
        end
      end
      snapshot.unassignable_ids = weights_to_ids(snapshot.unassignable_weights, people_names_hash)
      snapshot.assignable_ids = weights_to_ids(snapshot.assignable_weights, people_names_hash)
      snapshot.billing_ids = weights_to_ids(snapshot.billing_weights, people_names_hash)
      snapshot.non_billing_ids = weights_to_ids(snapshot.non_billing_weights, people_names_hash)
      snapshot.save!
    end

    remove_column :snapshots, :staff_weights
    remove_column :snapshots, :unassignable_weights
    remove_column :snapshots, :billing_weights
  end

  def ids_to_weights(ids, people_hash)
    ids.each_with_object(WeightedSet.new) do |id, set|
      set[people_hash[id]] = 100
    end
  end

  def weights_to_ids(weights, people_names_hash)
    weights.keys.map { |name| people_names_hash[name] }
  end

end
