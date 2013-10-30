require 'spec_helper'

describe Api::V1::NavbarsController do

  let(:person) { FactoryGirl.create(:person) }

  let!(:settings) { FactoryGirl.create(:t2_application, title: "Settings") }

  before do
    sign_in :user, person.user
    person.user.ensure_authentication_token!
  end

  def serialized_response
    JSON.parse(response.body)
  end

  describe '/GET /api/v1/navbar' do
    before do
      get :show
    end

    it "should return settings in the bottom" do
      settings_entry = serialized_response.find { |entry| entry['title'] == 'Settings' }
      settings_entry['top'].should be_false
    end

    it "should interpolate the authentication token into the application links" do
      token = person.user.authentication_token
      settings_entry = serialized_response.find { |entry| entry['title'] == 'Settings' }
      settings_entry['url'].should match(/authentication_token=#{token}/)
    end
  end
end

