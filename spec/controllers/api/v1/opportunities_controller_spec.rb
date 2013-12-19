require 'spec_helper'

describe Api::V1::OpportunitiesController do
  
  let(:person) {FactoryGirl.create(:person)}
  let(:another_person) { FactoryGirl.create(:person, email: 'another_person@neo.com') }
  let(:company) { FactoryGirl.create(:company) }

  before do
    4.times do
      FactoryGirl.create(:opportunity, person: person)
    end

    6.times do
      FactoryGirl.create(:opportunity, person: another_person)
    end

    sign_in :user, person.user
  end

  it 'should get all opportunities' do
    get :index

    opportunities = JSON.parse(response.body)
    opportunities["opportunities"].size.should eq (10)
    opportunities["opportunities"].select{ |opportunity| opportunity["owner"]["id"] == person.id }.size.should eq(4)
  end

  describe 'create an opportunity' do
    it 'should create with default values' do
      post :create

      opportunity = JSON.parse(response.body)
      opportunity["owner"]["name"].should eq(person.name)
      opportunity["stage"].should eq('new')
      opportunity["confidence"].should eq('warm')
      opportunity["title"].should eq("#{person.name}'s new opportunity")
    end

    it 'should allow any value and create company if it does not exist' do
      post :create, { opportunity: {company_name: 'company inc', title: 'some title', stage: 'won'} }

      opportunity = JSON.parse(response.body)
      opportunity["company"]["name"].should eq('company inc')
      opportunity["owner"]["name"].should eq(person.name)
      opportunity["stage"].should eq('won')
      opportunity["confidence"].should eq('warm')
      opportunity["title"].should eq("some title")
    end

    it 'should allow any value and use existent company' do
      post :create, { opportunity: {company_id: company.id, title: 'some title', stage: 'won'} }

      opportunity = JSON.parse(response.body)
      opportunity["company"]["name"].should eq(company.name)
      opportunity["owner"]["name"].should eq(person.name)
      opportunity["stage"].should eq('won')
      opportunity["confidence"].should eq('warm')
      opportunity["title"].should eq("some title")
    end

    describe 'contacts' do
      let(:contact) { FactoryGirl.create(:contact, company: company) }

      it 'should use an existent contact with company' do
        post :create, { opportunity: {company_id: company.id, contact: {name: contact.name, email: contact.email}} }

        opportunity = JSON.parse(response.body)
        opportunity["company"]["name"].should eq(company.name)
        opportunity["contact"]["name"].should eq(contact.name)
        opportunity["contact"]["email"].should eq(contact.email)
      end

      it 'should use an existent contact without company - associate opportunity to company' do
        post :create, { opportunity: {contact: {name: contact.name, email: contact.email}} }

        opportunity = JSON.parse(response.body)
        opportunity["company"]["name"].should eq(company.name)
        opportunity["contact"]["name"].should eq(contact.name)
        opportunity["contact"]["email"].should eq(contact.email)
      end

      it 'should create a contact with company - associate opportunity to company' do
        post :create, { opportunity: {company_id: company.id, contact: {name: 'foo', email: 'foo@bar.com'}} }

        opportunity = JSON.parse(response.body)
        opportunity["company"]["name"].should eq(company.name)
        opportunity["contact"]["name"].should eq('foo')
        opportunity["contact"]["email"].should eq('foo@bar.com')
      end

      it 'should create a contact without company - it should not associate opportunity to company' do
        post :create, { opportunity: {contact: {name: 'foo', email: 'foo@bar.com'}} }

        opportunity = JSON.parse(response.body)
        opportunity["contact"]["name"].should eq('foo')
        opportunity["contact"]["email"].should eq('foo@bar.com')
      end
    end
  end
  
  it 'update an opportunity' do
    put :update, { id: Opportunity.all.last.id, opportunity: { company_name: 'acme inc', confidence: 'warm', title: 'ux workshop', person_id: another_person.id } }

    opportunity = JSON.parse(response.body)
    opportunity["owner"]["name"].should eq(another_person.name)
    opportunity["stage"].should eq('new')
    opportunity["confidence"].should eq('warm')
    opportunity["title"].should eq("ux workshop")
  end

  it 'should allow to destroy' do
    delete :destroy, id: Opportunity.all.first.id
    response.status.should eq(200)
    Opportunity.all.count.should eq(9)
  end
end
