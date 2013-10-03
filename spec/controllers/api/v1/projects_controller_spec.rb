require 'spec_helper'

describe Api::V1::ProjectsController do

  before do
    sign_in :user, FactoryGirl.create(:user)
  end

  describe "GET #index" do
    it "should respond with list of projects" do
      projects = FactoryGirl.create_list :project, 2

      get :index

      resp = JSON.parse(response.body)
      resp.keys.should eql(["projects"])
      resp["projects"].should have(2).items
    end
  end
end

