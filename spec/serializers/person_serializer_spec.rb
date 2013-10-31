require 'spec_helper'

describe PersonSerializer do
  let(:tags) { %w(ios android) }

  let(:person) { FactoryGirl.create(:person, skill_list: tags) }

  let(:person_serialized) { PersonSerializer.new(person) }

  before do
    10.times { FactoryGirl.create(:person, skill_list: tags) }
  end

  it "should serialize skill tags" do
    person_serialized.skill_list.should eql(tags)
  end

  it "should serialize office" do
    person_serialized.office.should eql(person.office)
  end

  it "should include social links" do
    person_serialized.github.should eql(person.github)
    person_serialized.twitter.should eql(person.twitter)
  end

  it "should include personal links" do
    person_serialized.website.should eql(person.website)
    person_serialized.title.should eql(person.title)
    person_serialized.bio.should eql(person.bio)
  end

  it "should include similar people" do
    person_serialized.similar_people.count.should eql(5)
  end
end
