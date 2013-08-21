class T2Application < ActiveRecord::Base
  attr_accessible :icon, :position, :title, :url
  has_many :users
end
