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
  end
end
