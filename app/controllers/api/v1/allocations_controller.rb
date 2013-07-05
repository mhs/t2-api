class Api::V1::AllocationsController < ApplicationController
  # GET /allocations.json
  def index
    render json: Allocation.all
  end

  # GET /allocations/1.json
  def show
    allocation = Allocation.find(params[:id])
    render json: allocation
  end

  # POST /allocations.json
  def create
    allocation = Allocation.new(params[:allocation])
    if allocation.save
      render json: allocation, status: :created
    else
      render json: allocation.errors, status: :unprocessable_entity
    end
  end

  # PUT /allocations/1.json
  def update
    allocation = Allocation.find(params[:id])
    if allocation.update_attributes(params[:allocation])
      render json: allocation, status: :ok
    else
      render json: allocation.errors, status: :unprocessable_entity
    end
  end

  # DELETE /allocations/1.json
  def destroy
    allocation = Allocation.find(params[:id])
    allocation.destroy
    render json: nil, status: :ok
  end
end
