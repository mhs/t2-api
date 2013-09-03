class Api::V1::T2ApplicationsController < ApplicationController
  def index
    apps = T2Application.all
    render json: apps
  end
end
