require 'rails_helper'
require 'date_range_helper'

class DateTester
  include DateRangeHelper
end

describe "DateRangeHelper" do

  let(:tester) { DateTester.new }

  let(:wednesday)  { Date.new(2014, 02, 12) }
  let(:saturday)   { Date.new(2014, 02, 15) }
  let(:sunday)     { Date.new(2014, 02, 16) }

  describe "#weekend?" do
    it "will be falsey if a weekday" do
      expect(tester.weekend?(wednesday)).to be_falsey
    end

    it "will be truthy if a Saturday" do
      expect(tester.weekend?(saturday)).to be_truthy
    end

    it "will be truthy if Sunday" do
      expect(tester.weekend?(sunday)).to be_truthy
    end
  end

  describe "#weekday?" do
    it "will be truthy if a weekday" do
      expect(tester.weekday?(wednesday)).to be_truthy
    end

    it "will be falsey if a Saturday" do
      expect(tester.weekday?(saturday)).to be_falsey
    end

    it "will be falsey if Sunday" do
      expect(tester.weekday?(sunday)).to be_falsey
    end
  end
end
