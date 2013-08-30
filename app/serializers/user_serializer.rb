class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :office_id, :t2_application_id
  has_one :person, embed: :ids
end
