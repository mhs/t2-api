require 'spec_helper'

describe Api::V1::OpportunityNotesController do

  let(:person) { FactoryGirl.create(:person, email: 'person@neo.com') }
  let(:opportunity) { FactoryGirl.create(:opportunity, person: person) }
  let(:another_opportunity) { FactoryGirl.create(:opportunity, person: person) }
  let(:opportunity_note) { FactoryGirl.create(:opportunity_note, opportunity: opportunity, person: person) }

  before do
    sign_in :user, person.user
  end

  it 'should allow to create a note' do
    post :create, { opportunity_note: {opportunity: opportunity.id, detail: 'some note detail' } }

    note = JSON.parse(response.body)
    note["opportunity_note"]["detail"].should eq(OpportunityNote.first.detail)
  end

  it 'should allow to destroy' do
    delete :destroy, id: opportunity_note.id

    response.status.should eq(200)
    OpportunityNote.count.should eq(0)
  end

  it 'should allow to update' do
    put :update, { id: opportunity_note.id, opportunity_note: { opportunity: another_opportunity.id, detail: 'a new detail' } }

    note = JSON.parse(response.body)
    note["opportunity_note"]["detail"].should eq('a new detail')
    note["opportunity_note"]["opportunity"].should eq another_opportunity.id
  end
end
