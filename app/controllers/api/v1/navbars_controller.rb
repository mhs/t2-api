class Api::V1::NavbarsController < ApplicationController

  def show
    navbar = Navbar.new(T2Application.all)

    render json: navbar, root: false
  end
end
