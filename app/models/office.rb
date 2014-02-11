class Office < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :slug

  has_many :project_offices
  has_many_current :projects, :through => :project_offices
  has_many_current :people
  has_many_current :allocations, :through => :people

  SPECIAL_OFFICES = ["Headquarters", "Archived"]

  def self.active
    where(deleted_at: nil)
  end

  def self.standard
    where.not(name: SPECIAL_OFFICES)
  end

  def self.reporting
    active.standard
  end

  class SummaryOffice
    def name
      "Overview"
    end

    def id
      nil
    end

    def slug
      name.downcase
    end
  end
end
