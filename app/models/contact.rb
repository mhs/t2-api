class Contact < ActiveRecord::Base
  attr_accessible :name, :email, :phone

  belongs_to :company
  has_many :opportunities

  validates :email, uniqueness: true
end
