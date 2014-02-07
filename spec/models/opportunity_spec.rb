require 'spec_helper'

describe Opportunity do

  let(:person) { FactoryGirl.create(:person) }

  it 'should allow only cold/warm/hot confidence values' do
    cold = Opportunity.new(confidence: 'cold', stage: 'idea')
    cold.valid?.should eq true

    warm = Opportunity.new(confidence: 'warm', stage: 'idea')
    warm.valid?.should eq true

    hot = Opportunity.new(confidence: 'hot', stage: 'idea')
    hot.valid?.should eq true

    chill = Opportunity.new(confidence: 'chill', stage: 'idea')
    chill.valid?.should eq false
  end

  it 'should allow COLD/WARM/HOT and lower_case them' do
    cold = Opportunity.new(confidence: 'COLD', stage: 'idea')
    cold.valid?.should eq true
  end
   it 'should create with default values' do
     default_values = Opportunity.new
     default_values.person = person
     default_values.save

     default_values.confidence.should eq 'warm'
   end

  it 'should allow only valid stages' do
    idea = Opportunity.new(stage: 'idea')
    idea.valid?.should eq true

    contacted = Opportunity.new(stage: 'contacted')
    contacted.valid?.should eq true

    discovery = Opportunity.new(stage: 'discovery')
    discovery.valid?.should eq true

    scoped = Opportunity.new(stage: 'scoped')
    scoped.valid?.should eq true

    negotiation = Opportunity.new(stage: 'negotiation')
    negotiation.valid?.should eq true
  end

  it 'should allow NEW/ON_HOLD/... and lower_case them' do
    contacted = Opportunity.new(stage: 'CONTACTED')
    contacted.valid?.should eq true
  end

  it 'should have default order with created_at desc' do
    op_b = FactoryGirl.create(:opportunity_note, created_at: 2.days.ago).id
    op_a = FactoryGirl.create(:opportunity_note, created_at: 3.days.ago).id
    op_c = FactoryGirl.create(:opportunity_note, created_at: 1.days.ago).id

    OpportunityNote.all.map(&:id).should eql([op_c,op_b,op_a])
  end
end
