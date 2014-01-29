require 'spec_helper'

describe Api::V1::UnfiledNotesController do

  let(:person) { FactoryGirl.create(:person, email: 'person@neo.com') }
  let(:another_person) { FactoryGirl.create(:person, email: 'another_person@neo.com') }

  describe 'User must be logged in' do
    before do
      3.times do
        FactoryGirl.create(:opportunity_note, person: person, opportunity: nil)
      end

      sign_in :user, person.user
    end

    it 'should return all unfiled notes related to the user' do
      get :index

      notes = JSON.parse(response.body)
      notes['opportunity_notes'].size.should eq 3
      notes['opportunity_notes'].first["owner"].should eql(person.id)
    end
  end

  describe 'An unauthorized user' do
    before do
      another_person
    end

    it 'should allow if email is neo.com domain' do
      post :create, 'body-plain' => 'This is just some note', from: "#{person.name} <#{another_person.email}>"

      response.should be_success

      OpportunityNote.all.count.should eq(1)
    end

    it 'should not allow if email is not neo.com domain' do
      post :create, 'body-plain' => 'This is just some note', from: "user@example.com"

      note = JSON.parse(response.body)
      response.status.should eq(400)
      note['error'].should eq('Invalid note')

      OpportunityNote.all.count.should eq(0)
    end
  end
end
