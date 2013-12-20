class Api::V1::UnfiledNotesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :create
  before_filter :get_opportunity_note, only: [:update, :destroy]

  def index
    @notes = OpportunityNote.where(person_id: current_user.person.id).where(opportunity_id: nil)
    render json: @notes
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

  def update
    if @note.nil?
      render json: {error: 'There is no a note'}
    else
      opportunity_id = params[:note].delete(:opportunity_id).to_i

      @note.update_attributes(params[:note])

      unless opportunity_id.nil?
        opportunity = Opportunity.find(opportunity_id)
        @note.opportunity = opportunity unless opportunity.nil?
        @note.save
      end

      render json: nil, status: :ok
    end
  end

  def destroy
    if @note.nil?
      render json: {error: 'There is no a note'}
    else
      @note.destroy
      render json: nil, status: :ok
    end
  end

  private

  def get_opportunity_note
    @note = OpportunityNote.find(params[:id])
  end
end
