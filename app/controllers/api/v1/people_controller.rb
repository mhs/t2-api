class Api::V1::PeopleController < ApplicationController

  before_filter :fetch_person, only: [:show, :update, :similar]

  def index
    people = with_ids_from_params(Person.includes(:user, :project_allowances, :office, {:allocations => :project}))
    render json: people
  end

  def show
    render json: @person
  end

  def create
    attrs = params[:person].slice(*Person.editable_attributes)
    avatar = attrs.delete(:avatar)
    # null out blanks
    attrs.each do |k, v|
      attrs[k] = nil if v.blank?
    end
    if avatar && !avatar.is_a?(Hash)
      attrs[:avatar] = avatar
    end
    person = Person.new(attrs)
    person.office_id = params[:person][:office_id].to_i
    if person.save
      render json: person
    else
      render json: { errors: person.errors }, status: :unprocessable_entity
    end
  end

  def update
    # TODO: return 422 + sensible payload on errors
    attrs = params[:person].slice(*Person.editable_attributes)
    avatar = attrs.delete(:avatar)
    # null out blanks
    attrs.each do |k, v|
      attrs[k] = nil if v.blank?
    end
    if avatar && !avatar.is_a?(Hash)
      attrs[:avatar] = avatar
    end
    if @person.update_attributes(attrs)
      render json: @person
    else
      render json: { errors: @person.errors }, status: :unprocessable_entity
    end
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
