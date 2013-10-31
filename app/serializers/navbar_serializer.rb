class NavbarSerializer < ActiveModel::Serializer
  has_many :top, serializer: NavbarItemSerializer, root: false
  has_many :bottom, serializer: NavbarItemSerializer, root: false
end
