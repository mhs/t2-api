require 'rails_helper'

describe PersonSerializer do
  let(:tags) { %w(ios android) }

  let(:person) { FactoryGirl.create(:person, skill_list: tags) }

  let(:person_serialized) { PersonSerializer.new(person) }

  before do
    10.times { FactoryGirl.create(:person, skill_list: tags) }
  end

  it "should serialize office" do
    expect(person_serialized.office).to eql(person.office)
  end

  it "should include social links" do
    expect(person_serialized.github).to eql(person.github)
    expect(person_serialized.twitter).to eql(person.twitter)
  end

  it "should include personal links" do
    expect(person_serialized.website).to eql(person.website)
    expect(person_serialized.title).to eql(person.title)
    expect(person_serialized.bio).to eql(person.bio)
  end

  it "should serialize avatars" do
    expect(person_serialized.avatar).to be_kind_of(Hash)
    expect(person_serialized.avatar.keys).to match_array([:thumb, :small, :medium])
  end
end
