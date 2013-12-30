module DateRanges
  extend ActiveSupport::Concern

  module ClassMethods
    def within_date_range(start_date, end_date)
      begin
        old_start = _start_date
        old_end = _end_date
        self._start_date = start_date
        self._end_date = end_date
        yield
      ensure
        self._start_date = old_start
        self._end_date = old_end
      end
    end

    def _start_date
      Thread.current[:filter_start_date]
    end

    def _start_date=(v)
      Thread.current[:filter_start_date] = v
    end

    def _end_date
      Thread.current[:filter_end_date]
    end

    def _end_date=(v)
      Thread.current[:filter_end_date] = v
    end
  end
end
