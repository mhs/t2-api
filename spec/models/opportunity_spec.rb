require 'spec_helper'

describe Opportunity do

  let(:person) { FactoryGirl.create(:person) }

  it 'should allow only cold/warm/hot confidence values' do
    cold = Opportunity.new(confidence: 'cold')
    cold.valid?.should eq true

    warm = Opportunity.new(confidence: 'warm')
    warm.valid?.should eq true

    hot = Opportunity.new(confidence: 'hot')
    hot.valid?.should eq true

    chill = Opportunity.new(confidence: 'chill')
    chill.valid?.should eq false
  end

  it 'should allow COLD/WARM/HOT and lower_case them' do
    cold = Opportunity.new(confidence: 'COLD')
    cold.valid?.should eq true
  end
   it 'should create with default values' do
     default_values = Opportunity.new
     default_values.person = person
     default_values.save

     default_values.confidence.should eq 'warm'
     default_values.stage.should eq 'new'
     default_values.title.should eq "#{person.name}'s new opportunity"
   end

  it 'should allow only valid stages' do
    on_hold = Opportunity.new(stage: 'on_hold')
    on_hold.valid?.should eq true

    new = Opportunity.new(stage: 'new')
    new.valid?.should eq true

    scoped = Opportunity.new(stage: 'scoped')
    scoped.valid?.should eq true

    won = Opportunity.new(stage: 'won')
    won.valid?.should eq true

    lost = Opportunity.new(stage: 'lost')
    lost.valid?.should eq true

    rejected = Opportunity.new(stage: 'rejected')
    rejected.valid?.should eq true

    dont_know = Opportunity.new(stage: 'dont_know')
    dont_know.valid?.should eq false
  end

  it 'should allow NEW/ON_HOLD/... and lower_case them' do
    on_hold = Opportunity.new(stage: 'ON_HOLD')
    on_hold.valid?.should eq true
  end
end
