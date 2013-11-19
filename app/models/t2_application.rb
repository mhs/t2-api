class T2Application < ActiveRecord::Base
  attr_accessible :icon, :position, :title, :url, :classes
  has_many :users
end
