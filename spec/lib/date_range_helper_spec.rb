require 'spec_helper'
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
    it "will be false if a weekday" do
      expect(tester.weekend?(wednesday)).to be_false
    end

    it "will be true if a Saturday" do
      expect(tester.weekend?(saturday)).to be_true
    end

    it "will be true if Sunday" do
      expect(tester.weekend?(sunday)).to be_true
    end
  end

  describe "#weekday?" do
    it "will be true if a weekday" do
      expect(tester.weekday?(wednesday)).to be_true
    end

    it "will be false if a Saturday" do
      expect(tester.weekday?(saturday)).to be_false
    end

    it "will be false if Sunday" do
      expect(tester.weekday?(sunday)).to be_false
    end
  end
end
