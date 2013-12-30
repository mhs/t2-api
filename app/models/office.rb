class Office < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :slug

  has_many :project_offices
  has_many :projects, :through => :project_offices
  has_many_current :people
  has_many_current :allocations, :through => :people

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
