class Api::V1::OfficesController < Api::V1::BaseController
  def index
    @offices = with_ids_from_params(Office.includes(:projects, :people).references(:projects).order(:position))
    render json: @offices
  end

  def show
    @office = Office.find params[:id]
    render json: @office
  end
end
