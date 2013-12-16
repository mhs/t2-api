class Api::V1::UnfiledNotesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :create

  def index
    @notes = OpportunityNote.where(person_id: current_user.id)
    render json: @notes, root: false
  end

  def create
    person = Person.where(email: params[:email]).first

    if person.nil?
      render json: {error: 'only neo.com emails are accepted currently'}, status: 400

    else
      unfiled_note = OpportunityNote.new(detail: params[:detail])
      unfiled_note.person = person

      if unfiled_note.save
        render json: unfiled_note, root: false
      else
        render json: {error: 'the note is invalid'}, status: 400
      end
    end
  end

  def destroy

    note = OpportunityNote.find(params[:id])
    if note.nil?
      render json: {error: 'There is no a note'}
    else
      note.destroy
      render json: nil, status: :ok
    end
  end
end
