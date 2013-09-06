class PtoRequestSerializer < ActiveModel::Serializer
  attributes :id, :notes, :start_date, :end_date, :project_name, :project_id, :person_id, :updated_project_allowances

  def updated_project_allowances
    # project allowances were coming back as just the attributes, without the
    # used or available methods serialized. so i just wrote it in real quick.
    # maybe you know the fix.
    object.person.project_allowances.map do |pa|
      {
        project_id: pa.project_id,
        used: pa.used,
        hours: pa.hours,
        available: pa.available
      }
    end
  end
end

