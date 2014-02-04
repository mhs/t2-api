require 'spec_helper'

describe Api::V1::PeopleController do

  def serialized_response
    JSON.parse(response.body)
  end

  let(:person) { FactoryGirl.create(:person, skill_list: %w(ruby javascript)) }

  before do
    sign_in :user, person.user
  end

  describe 'Retriving Similar People to a Person' do



    describe 'Similar People' do
      before do
        3.times { FactoryGirl.create(:person, skill_list: %w(ruby javascript)) }
      end

      it 'should return an array of people' do
        pending "skill_list not implemented"

        get :similar, id: person.id

        serialized_response.size.should eql(3)
        serialized_response.first.keys.should =~ %w(email name id office_name avatar)
      end

      it 'should be able to limit results' do
        pending "skill_list not implemented"

        get :similar, id: person.id, limit: 1

        serialized_response.size.should eql(1)
      end
    end
  end

  describe 'Allocating upcoming vacation to new office member' do
    let(:person_params) { FactoryGirl.attributes_for(:person) }

    it "creates allocation for existing holidays in the same office" do
      person = mock(:person)
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
