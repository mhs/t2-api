require 'spec_helper'

describe Api::V1::OpportunitiesController do
  
  let(:person) {FactoryGirl.create(:person)}
  let(:another_person) { FactoryGirl.create(:person, email: 'another_person@neo.com') }
  let(:company) { FactoryGirl.create(:company) }
  let(:contact) { FactoryGirl.create(:contact, company: company) }

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
    opportunities["opportunities"].select{ |opportunity| opportunity["owner"] == person.id }.size.should eq(4)
  end

  describe 'OpportunityNotes' do
    before do
      4.times do
        FactoryGirl.create(:opportunity_note, opportunity: Opportunity.where(person_id: person.id).first)
      end
    end

    it 'should include notes' do
      pending 'not including notes yet'
      get :index

      opportunities = JSON.parse(response.body)
      opportunities["opportunities"].first["opportunity_notes"].size.should eq(4)
      opportunities["opportunities"].first["opportunity_notes"].first["detail"].should eq(OpportunityNote.first.detail)
    end
  end

  describe 'create an opportunity' do
    it 'should create with default values' do
      post :create

      opportunity = JSON.parse(response.body)
      opportunity["opportunity"]["stage"].should eq('idea')
      opportunity["opportunity"]["confidence"].should eq('warm')
      opportunity["opportunity"]["title"].should eq("#{person.name}'s new opportunity")
    end

    describe 'contacts' do

      it 'should use an existent contact with company' do
        post :create, { opportunity: {company: company.id, contact: contact.id} }

        opportunity = JSON.parse(response.body)
        opportunity["opportunity"]["company"].should eq(company.id)
        opportunity["opportunity"]["contact"].should eq(contact.id)
      end
    end
  end
  
  it 'update an opportunity' do
    put :update, { id: Opportunity.all.last.id, opportunity: { confidence: 'warm', title: 'ux workshop', owner: another_person.id } }

    opportunity = JSON.parse(response.body)

    opportunity["opportunity"]["owner"].should eq(another_person.id)
    opportunity["opportunity"]["stage"].should eq('idea')
    opportunity["opportunity"]["confidence"].should eq('warm')
    opportunity["opportunity"]["title"].should eq("ux workshop")
  end

  it 'should allow to destroy' do
    delete :destroy, id: Opportunity.all.first.id
    response.status.should eq(200)
    Opportunity.all.count.should eq(9)
  end

  describe 'Versioning' do
    before do
      PaperTrail.enabled = true
      post :create
      @opportunity = Opportunity.find JSON.parse(response.body)["opportunity"]["id"]
    end

    after do
      PaperTrail.enabled = false
    end

    it 'should keep a version of the model state' do
      @opportunity.versions.should_not be_empty
    end

    it 'should keep a track of the user that created the new version' do
      @opportunity.versions.last.user.should eql(person.user)
    end
  end
end
