class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :email, :office_id, :start_date, :end_date,
    :github, :twitter, :website, :title, :bio, :errors, :avatar, :office_slug, :role, :percent_billable
  has_many :allocations, embed: :ids
  has_one :user, embed: :ids
  has_one :office, embed: :ids

  def avatar
    {
      thumb: object.avatar.url(:thumb),
      small: object.avatar.url(:small),
      medium: object.avatar.url(:medium)
    }
  end

  def similar_people
    object.similar_people(5)
  end

  def office_slug
    office.slug
  end
end
