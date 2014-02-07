class OpportunityNote < ActiveRecord::Base

  default_scope order('created_at DESC')

  attr_accessible :detail

  validates :detail, presence: true

  belongs_to :person
  belongs_to :opportunity
end
