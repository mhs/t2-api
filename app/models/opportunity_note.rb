class OpportunityNote < ActiveRecord::Base
  attr_accessible :detail

  validates :detail, presence: true

  belongs_to :person
  belongs_to :opportunity
end
