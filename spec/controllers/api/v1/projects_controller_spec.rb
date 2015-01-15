require 'rails_helper'

describe Api::V1::ProjectsController do

  before do
    sign_in :user, FactoryGirl.create(:user)
  end

  describe "GET #index" do
    it "should respond with list of projects" do
      FactoryGirl.create_list :project, 2

      get :index, format: :json

      resp = JSON.parse(response.body)
      expect(resp.keys).to eql(["projects", "meta"])
      expect(resp["projects"].size).to eq(2)
    end
  end
end

