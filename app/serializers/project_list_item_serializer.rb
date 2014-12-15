class ProjectListItemSerializer < ActiveModel::Serializer

  attributes :id, :name, :start_date, :end_date, :investment_fridays

  has_many :offices, embed: :ids

end
