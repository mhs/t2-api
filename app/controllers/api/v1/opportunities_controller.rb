class Api::V1::OpportunitiesController < ApplicationController

  def index
    render json: OpportunityContext.all, root: false
  end

  def show
    opportunity = Opportunity.find(params[:id])
    if opportunity
      render json: opportunity, serializer: Opportunity::OpportunitySerializer
    else
      render json: {errors: {not_found: 'there is no opportunity'}}, status: :not_found
    end
  end

  def create
    respond_opportunity(OpportunityContext.new(current_user.person, params[:opportunity]).create_opportunity)
  end

  def update
    respond_opportunity(OpportunityContext.new(current_user.person, params[:opportunity]).update_opportunity(params[:id]))
  end

  def destroy
    context = OpportunityContext.new(current_user.person)
    render json: context.destroy_opportunity(params[:id])
  end

  private

  def respond_opportunity(context)
    if context[:is_saved]
      render json: context[:object], serializer: Opportunity::OpportunitySerializer
    else
      render json: context[:errors]
    end
  end
end
