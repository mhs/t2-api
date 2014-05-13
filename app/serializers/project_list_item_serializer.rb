class ProjectListItemSerializer < ActiveModel::Serializer

  attributes :id, :name, :start_date, :end_date, :selling_office

  has_one :selling_office

  def selling_office
    object.offices.sample
  end

end
