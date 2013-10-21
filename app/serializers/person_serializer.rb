class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :email, :unsellable, :office_id, :start_date, :end_date, :skill_list,
    :github, :twitter, :website, :title, :bio, :errors
  has_many :allocations, embed: :ids
  has_one :user
  has_one :office
  has_many :project_allowances
end
