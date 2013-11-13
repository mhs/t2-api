class Api::V1::NavbarsController < ApplicationController

  def show
    navbar = Navbar.new(T2Application.order(:position).all)

    render json: navbar, root: false
  end
end
