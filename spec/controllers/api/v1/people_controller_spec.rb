require 'rails_helper'

describe Api::V1::PeopleController do

  def serialized_response
    JSON.parse(response.body)
  end

  let(:person) { FactoryGirl.create(:person, skill_list: %w(ruby javascript)) }

  before do
    sign_in :user, person.user
  end

  describe 'Allocating upcoming vacation to new office member' do
    let(:person_params) { FactoryGirl.attributes_for(:person) }

    it "creates allocation for existing holidays in the same office" do
      person = double(:person)
      Person.stub(:create!).and_return(person)
      person.should_receive(:allocate_upcoming_holidays!)

      post :create, person: person_params
    end

    it "returns error json when error" do
      post :create, person: {}
      expect(serialized_response["errors"]).to_not be_empty
    end
  end
end
