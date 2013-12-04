class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :email, :unsellable, :office_id, :start_date, :end_date, :skill_list,
    :github, :twitter, :website, :title, :bio, :errors, :avatar, :office_slug, :role
  has_many :allocations, embed: :ids
  has_one :user, embed: :ids
  has_one :current_allocation, embed: :ids
  has_one :office, embed: :ids
  has_many :project_allowances, embed: :ids
  has_many :similar_people, serializer: MinimumPersonSerializer

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

  def current_allocation
    now = Date.today
    object.allocations.to_a.find do |alloc|
      alloc.end_date >= now && alloc.start_date <= now
    end
  end
end
