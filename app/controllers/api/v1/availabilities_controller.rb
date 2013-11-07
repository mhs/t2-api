class Api::V1::AvailabilitiesController < ApplicationController
  def index

    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    if params[:person_id].present?
      people = Person.where(id: params[:person_id].to_i)
    else
      # TODO: this can be more aggressively filtered for employee start dates
      #       and non-sellable people
      people = Person.billable
    end

    if params[:office_id].present?
      office = Office.find(params[:office_id].to_i)
      people = people.by_office(office)
    end

    availabilities = people.flat_map { |p| p.availabilities_for(start_date, end_date) }
    availabilities.reject! { |x| x.blank? }

    render json: availabilities
  end
end
