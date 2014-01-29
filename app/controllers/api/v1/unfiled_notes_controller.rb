class Api::V1::UnfiledNotesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :create

  def index
    @notes = OpportunityNote.where(person_id: current_user.person.id).where(opportunity_id: nil)
    render json: @notes, each_serializer: Opportunity::OpportunityNoteSerializer, root: 'opportunity_notes'
  end

  def create
    person = Person.where(email: unfiled_note_params[:sender]).first

    if person.nil?
      render json: {error: 'only neo.com emails are accepted currently'}, status: 400

    else
      unfiled_note = person.opportunity_notes.new(detail: unfiled_note_params["body-plain"])

      if unfiled_note.save
        render json: unfiled_note, serializer: Opportunity::OpportunityNoteSerializer
      else
        render json: {error: 'the note is invalid'}, status: 400
      end
    end
  end

  private

  def unfiled_note_params
    params.permit(:sender, :recipient, :subject, "body-plain", "stripped-text")
  end
end
