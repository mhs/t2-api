class Api::V1::PeopleController < ApplicationController

  before_filter :fetch_person, only: [:show, :update, :similar]

  def index
    people = with_ids_from_params(Person.includes(:user, :project_allowances, :allocations, :office))
    render json: people
  end

  def show
    render json: @person
  end

  def update
    # TODO: return 422 + sensible payload on errors
    attrs = params[:person].slice(*Person.editable_attributes)
    if attrs[:avatar] && attrs[:avatar].is_a?(Hash)
      attrs.delete(:avatar)
    end
    render json: @person, status: @person.update_attributes(attrs) ? 200 : 400
  end

  def profile
    person = Person.from_auth_token(params[:id])
    render json: person
  end

  def similar
    render json: @person.similar_people(params[:limit]), each_serializer: MinimumPersonSerializer, root: false
  end

  private

  def fetch_person
    @person = Person.find params[:id]
  end
end
