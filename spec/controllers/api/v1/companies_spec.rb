 require 'spec_helper'

 describe Api::V1::CompaniesController do

   describe 'Getting all Companies - potential clients' do

    let(:person) { FactoryGirl.create(:person) }

     before do
       5.times do
         FactoryGirl.create(:company)
       end
       sign_in :user, person.user
     end

     it "should display the entire list" do
       get :index

       companies = JSON.parse(response.body)
       companies.size.should eq(5)
     end

     it "should display the entire list order asc" do
       FactoryGirl.create(:company, name: 'zzzz')
       FactoryGirl.create(:company, name: 'AAaa')
       get :index

       companies = JSON.parse(response.body)
       companies.first["name"].should eq('AAaa')
       companies.first["name"].should be < companies.last["name"]
     end
   end
 end
