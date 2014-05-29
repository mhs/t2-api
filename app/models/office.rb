class Office < ActiveRecord::Base
  include HasManyCurrent

  attr_accessible :name, :notes, :slug

  has_many :project_offices
  has_many :office_holidays, :inverse_of => :office
  has_many :holidays, :through => :office_holidays
  has_many :revenue_items, inverse_of: :office
  has_many :sold_projects, class_name: "Project", foreign_key: :selling_office_id
  has_many_current :projects, :through => :project_offices
  has_many_current :people
  has_many_current :allocations, :through => :people

  SPECIAL_OFFICES = ["Headquarters", "Archived"]
  US_OFFICES = ["Cincinnati", "Columbus", "San Francisco", "New York"]

  def self.active
    where(deleted_at: nil)
  end

  def self.standard
    where.not(name: SPECIAL_OFFICES)
  end

  def self.us
    where(name: US_OFFICES)
  end

  def self.reporting
    active.standard
  end

  def summary?
    false
  end

  class SummaryOffice
    def name
      "Company-wide"
    end

    def id
      nil
    end

    def slug
      name.downcase
    end

    def summary?
      true
    end
  end
end
