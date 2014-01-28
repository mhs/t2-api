 require 'spec_helper'

 describe Api::V1::ContactsController do

  let(:person) { FactoryGirl.create(:person) }
  let(:contact) {FactoryGirl.create(:contact)}

   before do
     sign_in :user, person.user
   end

   it 'should allow to create a company' do
     post :create, {contact: {name: 'foo bar', email: 'foo@bar.com'}}
     company = JSON.parse(response.body)

     company["contact"]["email"].should eq "foo@bar.com"
   end

   it 'should allow to update a company' do

     post :update, {id: contact.id, contact: {email: 'foo@bar_contact.com', phone: '123456789'}}
     company = JSON.parse(response.body)

     company["contact"]["email"].should eq "foo@bar_contact.com"
     company["contact"]["phone"].should eq "123456789"
   end
 end
