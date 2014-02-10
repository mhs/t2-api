class Api::V1::CompaniesController < ApplicationController
  def index
    @companies = Company.order('name ASC')
    render json: @companies, root: 'companies'
  end
end
