class MinimumPersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :office_name

  def office_name
    object.office.name
  end
end
