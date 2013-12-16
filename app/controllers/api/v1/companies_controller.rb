class Api::V1::CompaniesController < ApplicationController
  def index
    @companies = Company.order('name ASC').all
    render json: @companies, root: false
  end
end
