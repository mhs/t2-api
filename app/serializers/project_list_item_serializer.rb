class ProjectListItemSerializer < ActiveModel::Serializer

  attributes :id, :name, :start_date, :end_date, :investment_fridays, :provisional

  has_many :offices, embed: :ids

end
