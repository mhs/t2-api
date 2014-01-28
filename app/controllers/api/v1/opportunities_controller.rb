class Api::V1::OpportunitiesController < ApplicationController

  def index
    render json: OpportunityContext.all, root: false
  end

  def show
    opportunity = Opportunity.find(params[:id])
    render json: opportunity, serializer: Opportunity::OpportunitySerializer
  end

  def create
    context = OpportunityContext.new(current_user.person)
    render json: context.create_opportunity(params[:opportunity]), serializer: Opportunity::OpportunitySerializer
  end

  def update
    context = OpportunityContext.new(current_user.person)
    render json: context.update_opportunity(params[:id], params[:opportunity]), serializer: Opportunity::OpportunitySerializer, root: 'opportunity'
  end

  def destroy
    context = OpportunityContext.new(current_user.person)
    render json: context.destroy_opportunity(params[:id])
  end
end
