require 'spec_helper'

describe Api::V1::OpportunityNotesController do

  let(:person) { FactoryGirl.create(:person, email: 'person@neo.com') }
  let(:opportunity) { FactoryGirl.create(:opportunity, person: person) }
  let(:opportunity_note) { FactoryGirl.create(:opportunity_note, opportunity: opportunity, person: person) }

  before do
    sign_in :user, person.user
  end

  it 'should allow to create a note' do
    post :create, { opportunity_id: opportunity.id, note: { detail: 'some note detail' } }

    note = JSON.parse(response.body)
    note["detail"].should eq(OpportunityNote.first.detail)
  end

  it 'should allow to destroy' do
    delete :destroy, opportunity_id: opportunity.id, id: opportunity_note.id
    response.status.should eq(200)
    OpportunityNote.count.should eq(0)
  end
end
