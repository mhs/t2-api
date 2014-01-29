class Api::V1::UnfiledNotesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :create

  before_filter :fetch_person_by_from_address, only: :create

  def index
    @notes = OpportunityNote.where(person_id: current_user.person.id).where(opportunity_id: nil)
    render json: @notes, each_serializer: Opportunity::OpportunityNoteSerializer, root: 'opportunity_notes'
  end

  def create
    if @person && @person.opportunity_notes.new(detail: unfiled_note_params["body-plain"]).save
      render json: {}, status: 200
    else
      render json: {error: 'Invalid note'}, status: 400
    end
  end

  private

  def unfiled_note_params
    params.permit(:from, :subject, "body-plain", "stripped-text")
  end

  def fetch_person_by_from_address
    email = unfiled_note_params[:from].scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i).first
    @person = Person.find_by_email(email)
  end
end
