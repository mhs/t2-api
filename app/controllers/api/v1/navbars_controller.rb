class Api::V1::NavbarsController < Api::V1::BaseController

  def show
    key = T2Application.maximum(:updated_at)
    navbar_json = Rails.cache.fetch key do
      Navbar.new(T2Application.order(:position).to_a).to_json
    end

    render json: navbar_json, root: false
  end
end
