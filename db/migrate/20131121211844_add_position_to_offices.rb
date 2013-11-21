class AddPositionToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :position, :integer

    Office.reset_column_information
    office_names = Office.pluck(:name).sort
    trailing_names = ["Headquarters", "Archived"]
    # heh
    office_names = (office_names - trailing_names) + trailing_names
    office_names.each_with_index do |name, index|
      Office.update_all({position: index+1}, {name: name})
    end
  end
end
