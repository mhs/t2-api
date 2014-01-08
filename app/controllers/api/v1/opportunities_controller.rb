class Api::V1::OpportunitiesController < ApplicationController

  def index
    @opportunities = Opportunity.order('expected_date_close ASC')
    render json: @opportunities
  end

  def create
    context = OpportunityContext.new(current_user.person)
    render json: context.create_opportunity(params[:opportunity])
  end

  def update
    context = OpportunityContext.new(current_user.person)
    render json: context.update_opportunity(params[:id], params[:opportunity])
  end

  def destroy
    context = OpportunityContext.new(current_user.person)
    render json: context.destroy_opportunity(params[:id])
  end
end
