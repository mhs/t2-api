class Api::V1::OpportunityNotesController < ApplicationController
  before_filter :set_opportunity_params, only: [:create, :update]
  before_filter :get_opportunity, only: [:create, :update, :destroy]
  before_filter :get_owner, only: [:create, :update]
  before_filter :get_opportunity_note, only: [:update, :destroy]

  def create
    if @opportunity.nil?
      render json: { error: 'opportunity does not exist' }, status: 404
    else
      note = OpportunityNote.new(@opportunity_params)
      note.person = @owner || current_user.person
      note.opportunity = @opportunity

      if note.save
        render json: note, serializer: Opportunity::OpportunityNoteSerializer
      else
        render json: { error: note.errors }, status: 400
      end
    end
  end
  
  def update
    if @opportunity_note.nil?
      render json: {error: 'opportunity note does not exist'}, status: 404
    else
      @opportunity_note.update_attributes(params[:note])

      render json: @opportunity_note, root: false
    end
  end

  def destroy
    if @opportunity_note.nil?
      render json: { error: 'opportunity note does not exist' }, status: 404
    else
      @opportunity_note.destroy
      render json: nil, status: :ok
    end
  end

  private

  def set_opportunity_params
    @opportunity_params = params[:opportunity_note]
  end

  def get_opportunity
    @opportunity = Opportunity.find(@opportunity_params.delete(:opportunity))
  end

  def get_owner
    @owner = Person.find(@opportunity_params.delete(:owner))
  end

  def get_opportunity_note
    @opportunity_note = @opportunity.opportunity_notes.find(params[:id]) unless @opportunity.nil?
  end
end
