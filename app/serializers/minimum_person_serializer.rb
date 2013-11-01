class MinimumPersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :office_name, :avatar

  def avatar
    {
      thumb: object.avatar.url(:thumb),
      small: object.avatar.url(:small),
      medium: object.avatar.url(:medium)
    }
  end

  def office_name
    object.office.name
  end
end
