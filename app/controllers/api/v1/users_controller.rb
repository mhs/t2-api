class Api::V1::UsersController < ApplicationController

  def show
    user = User.find(params[:id])
    render json: user
  end

  def update
    user = User.find(params[:id])
    if user.update_attributes(params[:user])
      render json: user, status: :ok
    else
      render json: { errors: user.errors }, status: unprocessable_entity
    end
  end

end

