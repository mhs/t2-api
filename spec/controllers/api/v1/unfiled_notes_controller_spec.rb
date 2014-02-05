require 'spec_helper'

describe Api::V1::UnfiledNotesController do

  let(:person) { FactoryGirl.create(:person, email: 'person@neo.com') }
  let(:another_person) { FactoryGirl.create(:person, email: 'another_person@neo.com') }
  let(:opportunity) { FactoryGirl.create(:opportunity, person: person) }

  describe 'User must be logged in' do
    before do
      3.times do
        FactoryGirl.create(:opportunity_note, person: person, opportunity: nil)
      end

      3.times do
        FactoryGirl.create(:opportunity_note, person: person, opportunity: opportunity)
      end

      3.times do
        FactoryGirl.create(:opportunity_note, person: another_person, opportunity: nil)
      end

      sign_in :user, person.user
    end

    it 'should return all unfiled notes related to the user' do
      pending 'must review implementation'
      get :index

      notes = JSON.parse(response.body)
      notes['unfiled_notes'].size.should eq 3
      notes['unfiled_notes'].first["owner"]["email"].should eq(person.email)
      notes['unfiled_notes'].first["owner"]["name"].should eq(person.name)
    end

    it 'should allow to destroy' do
      delete :destroy, id: OpportunityNote.all.first.id
      response.status.should eq(200)
      OpportunityNote.all.count.should eq(8)
    end

    it 'should allow to file a note' do
      note = OpportunityNote.first
      note.opportunity.should be nil

      put :update, { id:  note.id, note: { opportunity_id:  opportunity.id, detail: 'a detail text'}}

      response.status.should eq 200
      OpportunityNote.find(note.id).opportunity.should eq opportunity
    end
  end

  describe 'An unauthorized user' do
    before do
      another_person
    end

    it 'should allow if email is neo.com domain' do
      pending 'must review implementation'
      post :create, detail: 'This is just some note', email: 'another_person@neo.com'

      note = JSON.parse(response.body)
      note['owner']['email'].should eq('another_person@neo.com')

      OpportunityNote.all.count.should eq(1)
    end

    it 'should not allow if email is not neo.com domain' do
      post :create, detail: 'This is just some note', email: 'another_person@anemail.com'

      note = JSON.parse(response.body)
      response.status.should eq(400)
      note['error'].should eq('only neo.com emails are accepted currently')

      OpportunityNote.all.count.should eq(0)
    end
  end
end