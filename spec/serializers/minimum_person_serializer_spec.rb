require 'rails_helper'

describe MinimumPersonSerializer do
  let(:person) { FactoryGirl.create(:person) }

  let(:person_serialized) { MinimumPersonSerializer.new(person) }

  it "should serialize office_name" do
    expect(person_serialized.office_name).to eql(person.office.name)
  end

  it "should serialize avatars" do
    expect(person_serialized.avatar).to be_kind_of(Hash)
    expect(person_serialized.avatar.keys).to match_array([:thumb, :small, :medium])
  end
end
