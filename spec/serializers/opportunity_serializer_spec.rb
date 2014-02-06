require 'spec_helper'

describe Opportunity::OpportunitySerializer do

  let(:opportunity) { FactoryGirl.create(:opportunity) }

  let(:opportunity_serialized) { Opportunity::OpportunitySerializer.new(opportunity) }

  it "should serialize with root element" do
    opportunity_serialized.as_json.keys.should eql([:opportunity])
  end

  it "should return opportunity notes ordered by created_at desc" do
    op_b = FactoryGirl.create(:opportunity_note, created_at: 2.days.ago, opportunity: opportunity).id
    op_a = FactoryGirl.create(:opportunity_note, created_at: 3.days.ago, opportunity: opportunity).id
    op_c = FactoryGirl.create(:opportunity_note, created_at: 1.days.ago, opportunity: opportunity).id

    opportunity_serialized.as_json[:opportunity][:opportunity_notes].should eql([op_c,op_b,op_a])
  end
end
