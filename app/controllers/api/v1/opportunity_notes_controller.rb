class Api::V1::OpportunityNotesController < ApplicationController
  before_filter :set_opportunity_params, only: [:create, :update]
  before_filter :get_opportunity, only: [:create, :update]
  before_filter :get_owner, only: [:create, :update]
  before_filter :get_opportunity_note, only: [:update, :destroy]

  def create
    if @opportunity.nil?
      render json: { errors: 'opportunity does not exist' }, status: :unprocessable_entity
    else
      note = OpportunityNote.new(@opportunity_params)
      note.person = @owner || current_user.person
      note.opportunity = @opportunity

      if note.save
        render json: note, serializer: Opportunity::OpportunityNoteSerializer
      else
        render json: { errors: note.errors }, status: 400
      end
    end
  end

  def update
    if @opportunity_note.nil?
      render json: {error: 'opportunity note does not exist'}, status: :unprocessable_entity
    else
      @opportunity_note.opportunity = @opportunity unless @opportunity.nil?
      @opportunity_note.update_attributes(opportunity_note_params)

      render json: @opportunity_note, serializer: Opportunity::OpportunityNoteSerializer
    end
  end

  def destroy
    if @opportunity_note.nil?
      render json: { errors: 'opportunity note does not exist' }, status: :unprocessable_entity
    else
      @opportunity_note.destroy
      render json: nil, status: :ok
    end
  end

  private

  def opportunity_note_params
    params.require(:opportunity_note).permit(:opportunity, :detail)
  end

  def set_opportunity_params
    @opportunity_params = params[:opportunity_note]
  end

  def get_opportunity
    @opportunity = Opportunity.find(@opportunity_params.delete(:opportunity))
  end

  def get_owner
    @owner = Person.find(@opportunity_params.delete(:owner)) unless @opportunity_params[:owner].nil?
  end

  def get_opportunity_note
    @opportunity_note = OpportunityNote.find(params[:id])
  end
end
