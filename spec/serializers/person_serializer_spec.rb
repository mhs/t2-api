require 'spec_helper'

describe PersonSerializer do
  let(:person) { FactoryGirl.create(:person) }

  let(:person_serialized) { PersonSerializer.new(person) }

  let(:tags) { %w(ios android) }

  before do
    person.skill_list = tags
    person.save!
  end

  it "should serialize skill tags" do
    person_serialized.skill_list.should eql(tags)
  end

  it "should serialize office" do
    person_serialized.office.should eql(person.office)
  end
end
