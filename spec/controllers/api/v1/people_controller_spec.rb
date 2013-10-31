require 'spec_helper'

describe Api::V1::PeopleController do

  def serialized_response
    JSON.parse(response.body)
  end

  describe 'Retriving Similar People to a Person' do

    let(:person) { FactoryGirl.create(:person, skill_list: %w(ruby javascript)) }

    before do
      sign_in :user, person.user
    end

    describe 'Similar People' do
      before do
        3.times { FactoryGirl.create(:person, skill_list: %w(ruby javascript)) }
      end

      it 'should return an array of people' do
        get :similar, id: person.id

        serialized_response.size.should eql(3)
        serialized_response.first.keys.should =~ %w(email name id office_name)
      end

      it 'should be able to limit results' do
        get :similar, id: person.id, limit: 1

        serialized_response.size.should eql(1)
      end
    end
  end
end
