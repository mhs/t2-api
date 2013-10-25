require 'spec_helper'

describe MinimumPersonSerializer do
  let(:person) { FactoryGirl.create(:person) }

  let(:person_serialized) { MinimumPersonSerializer.new(person) }

  it "should serialize office_name" do
    person_serialized.office_name.should eql(person.office.name)
  end
end
