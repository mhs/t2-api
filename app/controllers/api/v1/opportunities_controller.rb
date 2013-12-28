class Api::V1::OpportunitiesController < ApplicationController
  before_filter :get_opportunity, only: [:update, :destroy]
  before_filter :get_company_params, only: [:update]
  before_filter :get_contact_params, only: [:update]
  before_filter :set_company_with_contact, only: [:update]
  before_filter :get_owner_params, only: [:update]

  def index
    @opportunities = Opportunity.all
    render json: @opportunities
  end

  def create
    context = OpportunityContext.new(current_user.person)
    render json: context.create_opportunity(params[:opportunity])
  end

  def update
    
    if @opportunity
      @opportunity.update_attributes(params[:opportunity])
      set_opportunity
    else
      render json: {error: 'it does not exist an opportunity'}
    end
  end

  def destroy
    if @opportunity.nil?
      render json: {error: 'There is no an opportunity'}
    else
      @opportunity.destroy
      render json: nil, status: :ok
    end
  end

  private

  def get_opportunity
    @opportunity = Opportunity.find(params[:id])
  end
end
