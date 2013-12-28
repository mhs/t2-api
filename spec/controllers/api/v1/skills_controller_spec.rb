require 'spec_helper'

describe Api::V1::SkillsController do

  let(:person) { FactoryGirl.create(:person) }

  before do
    sign_in :user, person.user
  end

  def serialized_response
    JSON.parse(response.body)
  end

  describe '/GET /api/v1/skills' do
    before do
      @person = FactoryGirl.create(:person, skill_list: %w(ruby javascript))
      get :index
    end

    it 'should return all skills' do
      pending "skill_list not implemented"

      serialized_response.count.should eql(2)
    end

    it 'should return associated people' do
      pending "skill_list not implemented"

      serialized_response.first["people"].first["email"].should eql(@person.email)
    end
  end
end
