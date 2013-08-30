class Api::V1::PeopleController < ApplicationController
  def index
    people = Person.all
    render json: people
  end

  def show
    person = Person.find params[:id]
    render json: person
  end

  def profile
    person = Person.from_auth_token(params[:id])
    render json: person
  end

  def update
    person = Person.find params[:person][:id]
    if person.user.update_attributes t2_application_id: params[:person][:t2_application_id]
      head :ok
    else
      head :bad_request
    end
  end
end
