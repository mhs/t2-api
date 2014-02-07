require 'spec_helper'

describe Api::V1::UnfiledNotesController do

  let(:person) { FactoryGirl.create(:person, email: 'person@neo.com') }
  let(:another_person) { FactoryGirl.create(:person, email: 'another_person@neo.com') }

  describe 'An unauthorized user with httpbasic' do
    before do
      another_person
      @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("crm_neo:T2_crm_n30")
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
