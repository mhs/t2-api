class ProjectListItemSerializer < ActiveModel::Serializer

  attributes :id, :name, :start_date, :end_date

  has_one :selling_office, embed: :ids

  def selling_office
    object.offices.sample
  end

end
