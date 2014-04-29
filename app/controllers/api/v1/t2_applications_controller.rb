class Api::V1::T2ApplicationsController < Api::V1::BaseController
  def index
    apps = T2Application.all
    render json: apps
  end
end
