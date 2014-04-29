class Api::V1::NavbarsController < Api::V1::BaseController

  def show
    navbar = Navbar.new(T2Application.order(:position).to_a)

    render json: navbar, root: false
  end
end
