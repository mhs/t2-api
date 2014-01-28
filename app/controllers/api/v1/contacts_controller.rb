class Api::V1::ContactsController < ApplicationController
  def create
    contact = Contact.new(params[:contact])

    if contact.save
      render json: contact, serializer: Opportunity::OpportunityContactSerializer, root: 'contact'
    else
      render json: { error: contact.errors }, status: 400
    end
  end

  def update
    contact = Contact.find(params[:id])

    if contact
      contact.update_attributes(params[:contact])
      render json: contact, serializer: Opportunity::OpportunityContactSerializer, root: 'contact'
    else
      render json: { error: contact.errors }, status: 400
    end
  end
end
