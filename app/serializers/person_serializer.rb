class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :email, :office_id, :start_date, :end_date,
    :github, :twitter, :website, :title, :bio, :errors, :avatar, :office_slug, :role, :percent_billable
  has_many :allocations, embed: :ids
  has_one :user, embed: :ids
  has_one :current_allocation, embed: :ids, include: true, root: :allocations
  has_one :office, embed: :ids
  # has_many :project_allowances, embed: :ids

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
    object.allocations.to_a.select do |alloc|
      alloc.end_date >= now && alloc.start_date <= now
    end.sort_by { |x| x.vacation? ? 0 : 1 }.first
  end
end
