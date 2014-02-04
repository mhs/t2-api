class Api::V1::PeopleController < ApplicationController

  before_filter :fetch_person, only: [:show, :update, :similar]

  def index
    people = []
    Person.within_date_range(Date.today, Date.today) do
      people = with_ids_from_params(Person.includes(:user, :project_allowances, :office, :allocations)).to_a
    end
    # the above will omit people who have left the company; add them back
    people += with_ids_from_params(Person.includes(:user, :project_allowances, :office).where('end_date < ?', Date.today))
    render json: people, each_serializer: PersonWithCurrentSerializer
  end

  def show
    render json: @person
  end

  def create
    person = nil
    begin
      Person.transaction do
        person = Person.create!(person_params)
        person.allocate_upcoming_holidays!
      end

      render json: person
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors }, status: :unprocessable_entity
    end
  end

  def update
    # TODO: return 422 + sensible payload on errors
    if @person.update_attributes(person_params)
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

  def person_params
    attrs = if params[:action] == "create"
              params[:person].slice(*Person.accessible_attributes)
            else
              params[:person].slice(*Person.editable_attributes)
            end

    avatar = attrs.delete(:avatar)
    # null out blanks
    attrs.each do |k, v|
      attrs[k] = nil if v.blank?
    end
    if avatar && !avatar.is_a?(Hash)
      attrs[:avatar] = avatar
    end

    attrs
  end

end
