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
        @serialized_person["avatar"]["thumb"].should_not be_empty
        @serialized_person["avatar"]["small"].should_not be_empty
        @serialized_person["avatar"]["medium"].should_not be_empty
      end
    end

    # TODO: uncomment this when there are validations that can fail
    # describe 'When fails' do
    #   before do
    #     update(website: 'invalid website')
    #   end

    #   it 'should respond with status 400' do
    #     response.status.should eql(400)
    #   end

    #   it 'should add error fields on the response' do
    #     @serialized_person["errors"]["website"].should_not be_nil
    #   end
    # end
  end
end
