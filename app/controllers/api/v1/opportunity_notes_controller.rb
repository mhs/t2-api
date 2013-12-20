class Api::V1::OpportunityNotesController < ApplicationController
  before_filter :get_opportunity, only: [:create, :update, :destroy]
  before_filter :get_opportunity_note, only: [:update, :destroy]

  def create
    if @opportunity.nil?
      render json: { error: 'opportunity does not exist' }, status: 404
    else
      note = OpportunityNote.new(params[:note])
      note.opportunity = @opportunity
      note.person = current_user.person

      if note.save
        render json: note, root: false
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

  def get_opportunity
    @opportunity = Opportunity.find(params[:opportunity_id])
  end

  def get_opportunity_note
    @opportunity_note = @opportunity.opportunity_notes.find(params[:id]) unless @opportunity.nil?
  end
end
