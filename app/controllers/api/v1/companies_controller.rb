class Api::V1::CompaniesController < ApplicationController
  def index
    @companies = Company.order('name ASC').all
    render json: @companies, root: 'companies'
  end
end
