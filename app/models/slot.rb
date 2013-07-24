class Slot < ActiveRecord::Base
  # include TimeLimit

  attr_accessible :project, :project_id, :start_date, :end_date

  belongs_to :project
  has_many :allocations, dependent: :nullify

  validates_presence_of :project, :start_date, :end_date

  def free_date_ranges
    free_date_ranges = [[self.start_date, self.end_date]]
    self.allocations.each do |allocation|
      free_date_ranges.each do |range|
        if allocation.start_date >= range.first && allocation.end_date <= range.last
          if allocation.start_date > range.first
            free_date_ranges << [range.first, allocation.start_date.prev_day]
          end
          if allocation.end_date < range.last
            free_date_ranges << [allocation.end_date.next_day, range.last]
          end
          free_date_ranges.delete range
          break
        end
      end
    end
    free_date_ranges
  end

  def serializable_hash options
    options = options.try(:clone) || {}
    options[:methods] ||= []
    options[:methods] << :free_date_ranges

    super options
  end
end

