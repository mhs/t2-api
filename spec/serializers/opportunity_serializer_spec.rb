require 'spec_helper'

describe Opportunity::OpportunitySerializer do

  let(:opportunity) { FactoryGirl.create(:opportunity) }

  let(:opportunity_serialized) { Opportunity::OpportunitySerializer.new(opportunity) }

  it "should serialize with root element" do
    opportunity_serialized.as_json.keys.should eql([:opportunity])
  end
end
