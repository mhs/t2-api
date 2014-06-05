class Api::V1::ProjectsController < Api::V1::BaseController

  respond_to :json

  before_action :cleanup_params, only: :index

  def index
    proxy = Project.search(params[:search]).for_office_id(params[:office_id]).base_order
    proxy = proxy.order(:name)
    proxy = proxy.archived(params[:archived])
    projects = proxy.paginate(page: params[:page])
    respond_with(projects, each_serializer: ProjectListItemSerializer, meta: { page: params[:page].to_i, total: projects.total_pages})
  end

  def show
    project = Project.find(params[:id])
    render json: project
  end

  def create
    project = Project.new(params[:project])
    if project.save
      render json: project, status: :created
    else
      render json: { errors: project.errors }, status: :unprocessable_entity
    end
  end

  def update
    project = Project.find(params[:id])
    if project.update_attributes(params[:project])
      render json: project, status: :ok
    else
      render json: { errors: project.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    project = Project.find(params[:id])
    project.destroy
    render json: nil, status: :ok
  end


  private

  def cleanup_params
    params[:archived] = params[:archived] == 'true' ? true : false
    params[:page] = params[:page] || 1
  end

end
