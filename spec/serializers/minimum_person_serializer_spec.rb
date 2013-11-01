require 'spec_helper'

describe MinimumPersonSerializer do
  let(:person) { FactoryGirl.create(:person) }

  let(:person_serialized) { MinimumPersonSerializer.new(person) }

  it "should serialize office_name" do
    person_serialized.office_name.should eql(person.office.name)
  end

  it "should serialize avatars" do
    person_serialized.avatar.should be_kind_of(Hash)
    person_serialized.avatar.keys.should =~ [:thumb, :small, :medium]
  end
end
