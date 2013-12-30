module HasManyCurrent
  extend ActiveSupport::Concern

  included do
    ActiveRecord::Base.send(:include, DateRanges) unless ActiveRecord::Base < DateRanges
  end

  module ClassMethods
    def has_many_current(name, options={})
      has_many name, filter_lambda(name), options
    end

    private

    def filter_lambda(name)
      # apply start_date and end_date to the specified scope.
      # This will be instance_eval'ed onto the Relation
      -> {
        s = ActiveRecord::Base._start_date
        e = ActiveRecord::Base._end_date
        rel = self
        # NOTE: table_name will not be correct if we're working on an alias
        #       use bare Arel to avoid trouble
        rel = rel.where(table[:start_date].lteq(e).or(table[:start_date].eq(nil))) if e
        rel = rel.where(table[:end_date].gteq(s).or(table[:end_date].eq(nil))) if s
        rel
      }
    end
  end
end
