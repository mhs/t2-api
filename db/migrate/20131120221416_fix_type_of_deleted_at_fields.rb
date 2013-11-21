class FixTypeOfDeletedAtFields < ActiveRecord::Migration
  def up
    # tricky: we can't just do change_column because PG won't cast
    # time columns to datetime
    #
    # old values in deleted_at are worthless; updated_at also isn't helpful
    # punt and make them all deleted now

    fiddle(Office)
    fiddle(Person)
    fiddle(Project)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def fiddle(klass)
    ids = klass.unscoped.where('deleted_at IS NOT NULL').pluck(:id)
    remove_column(klass.table_name, :deleted_at)
    add_column(klass.table_name, :deleted_at, :datetime)
    klass.reset_column_information
    klass.update_all({ deleted_at: Time.now }, { id: ids })
  end
end
