class Office < ActiveRecord::Base
  attr_accessible :name, :notes, :slug

  has_many :project_offices
  has_many :projects, :through => :project_offices
  has_many :people
  has_many :allocations, :through => :people

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
