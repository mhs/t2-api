class Api::V1::PtoRequestsController < ApplicationController

  def index
    person = Person.find params[:person_id]
    pto_requests = person.pto_requests
    render json: pto_requests, each_serializer: PtoRequestSerializer
  end

  def create
    pto_request = Allocation.new(params[:pto_request])
    if pto_request.save
      render json: pto_request, serializer: PtoRequestSerializer, status: :created
    else
      render json: pto_request.errors, status: :unprocessable_entity
    end
  end

  def update
    pto_request = Allocation.find(params[:id])
    if pto_request.update_attributes(params[:pto_request])
      render json: pto_request, serializer: PtoRequestSerializer, status: :updated
    else
      render json: pto_request.errors, status: :unprocessable_entity
    end
  end

end

