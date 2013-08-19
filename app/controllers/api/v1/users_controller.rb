class Api::V1::UsersController < ApplicationController
  def show
    @user = User.where("id = ? OR authentication_token = ?", params[:id].to_i, params[:id]).first
    render json: @user
  end
end

