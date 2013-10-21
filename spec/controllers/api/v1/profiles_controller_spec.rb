require 'spec_helper'

describe Api::V1::ProfilesController do

  describe 'Updating Person Profile' do

    let(:person) { FactoryGirl.create(:person) }

    before do
      sign_in :user, person.user
    end

    describe 'When succeed' do
      before do
        put :update, person: {website: 'http://mypersonalwebsite.com'}
      end

      it 'should respond with status 200' do
        response.status.should eql(200)
      end

      it 'should update person website' do
        JSON.parse(response.body)["person"]["website"].should eql("http://mypersonalwebsite.com")
      end
    end

    describe 'When fails' do
      before do
        put :update, person: {website: 'invalid website'}
      end

      it 'should respond with status 400' do
        response.status.should eql(400)
      end

      it 'should add error fields on the response' do
        JSON.parse(response.body)["person"]["errors"]["website"].should_not be_nil
      end
    end
  end
end
