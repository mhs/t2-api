class Api::V1::CompaniesController < ApplicationController
  def create
    company = Company.new(params[:company])

    if company.save
      render json: company, serializer: Opportunity::OpportunityCompanySerializer, root: 'company'
    else
      render json: { error: note.errors }, status: 400
    end
  end
end
