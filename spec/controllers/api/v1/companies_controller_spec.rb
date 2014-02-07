 require 'spec_helper'

 describe Api::V1::CompaniesController do

  let(:person) { FactoryGirl.create(:person) }

   before do
     5.times do
       FactoryGirl.create(:company)
     end

     sign_in :user, person.user
   end

   it 'should allow to create a company' do
     post :create, {company: {name: 'foo inc'}}
     company = JSON.parse(response.body)

     company["company"]["name"].should eq "foo inc"
     Company.count.should eq 6
   end
 end
