require 'rails_helper'

describe Api::V1::ProfilesController do

  describe 'Updating Person Profile' do

    def update(person_attributes={})
      put :update, person: person_attributes
      @serialized_person = JSON.parse(response.body)["person"]
    end

    let(:person) { FactoryGirl.create(:person) }

    before do
      sign_in :user, person.user
    end

    describe 'When succeed' do

      it 'should respond with status 200' do
        update
        expect(response.status).to eql(200)
      end

      it 'should update person attributes' do
        update(website: "http://mypersonalwebsite.com")
        expect(@serialized_person["website"]).to eql("http://mypersonalwebsite.com")
      end

      it 'should be able to update avatar' do
        update(avatar: fixture_file_upload("/images/neo.png"))
        expect(@serialized_person["avatar"]).to be_kind_of(Hash)
        expect(@serialized_person["avatar"]["thumb"]).not_to be_empty
        expect(@serialized_person["avatar"]["small"]).not_to be_empty
        expect(@serialized_person["avatar"]["medium"]).not_to be_empty
      end
    end
  end
end
