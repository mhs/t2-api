class Api::V1::NavbarsController < ApplicationController

  def show
    apps = T2Application.order('position ASC').all
    render json: apps, each_serializer: NavbarSerializer, root: false
  end
end
