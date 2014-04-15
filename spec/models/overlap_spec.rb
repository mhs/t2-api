require 'spec_helper'
describe Overlap do
  let(:person) { double }
  let(:start_date) { Date.today.beginning_of_week }
  let(:initial) { Overlap.new(person: person, start_date: day(0), end_date: day(14)) }
  let(:result) { initial.overlaps_for(alloc) }

  def day(offset)
    start_date + offset.days
  end

  describe "overlaps_for" do

    context "allocation does not intersect" do
      let(:alloc) { double(start_date: day(-2), end_date: day(-1), percent_allocated: 100) }

      it "returns the original" do
        expect(result).to eq([initial])
      end
    end

    context "allocation completely overlaps" do
      let(:alloc) { double(start_date: day(-2), end_date: day(20), percent_allocated: 100) }

      it "returns one overlap" do
        expect(result.size).to eq(1)
      end

      it "sets the percent_allocated" do
        expect(result.first.percent_allocated).to eq(alloc.percent_allocated)
      end

      it "keeps the original date range" do
        expect(result.first.start_date).to eq(initial.start_date)
        expect(result.first.end_date).to eq(initial.end_date)
      end

      it "set the allocation" do
        expect(result.first.allocations).to eq([alloc])
      end
    end

    context "allocation intersects at inital start" do
      let(:alloc) { double(start_date: day(0), end_date: day(2), percent_allocated: 100) }

      it "returns two overlaps" do
        expect(result.size).to eq(2)
      end

      it "has a first overlap that matches the initial start and alloc end" do
        expect(result[0].start_date).to eq(initial.start_date)
        expect(result[0].end_date).to eq(alloc.end_date)
        expect(result[0].allocations).to eq([alloc])
      end

      it "has a second overlap that matches the alloc start and initial end" do
        expect(result[1].start_date).to eq(alloc.end_date + 1.day)
        expect(result[1].end_date).to eq(initial.end_date)
        expect(result[1].allocations).to be_empty
      end
    end

    context "allocation intesects at our end" do
      # return two things
      let(:alloc) { double(start_date: day(10), end_date: day(20), percent_allocated: 100) }

      it "returns two overlaps" do
        expect(result.size).to eq(2)
      end

      it "has a first overlap that matches the initial start and alloc start" do
        expect(result[0].start_date).to eq(initial.start_date)
        expect(result[0].end_date).to eq(alloc.start_date - 1.day)
        expect(result[0].allocations).to be_empty
      end

      it "has a second overlap that matches the alloc end and initial end" do
        expect(result[1].start_date).to eq(alloc.start_date)
        expect(result[1].end_date).to eq(initial.end_date)
        expect(result[1].allocations).to eq([alloc])
      end
    end

    context "allocation intersects in the middle" do
      # return three things
      let(:alloc) { double(start_date: day(10), end_date: day(12), percent_allocated: 100) }

      it "returns three overlaps" do
        expect(result.size).to eq(3)
      end

      it "has a first overlap that matches the initial start and alloc start" do
        expect(result[0].start_date).to eq(initial.start_date)
        expect(result[0].end_date).to eq(alloc.start_date - 1.day)
        expect(result[0].allocations).to be_empty
      end

      it "has a second overlap that matches the alloc start and alloc end" do
        expect(result[1].start_date).to eq(alloc.start_date)
        expect(result[1].end_date).to eq(alloc.end_date)
        expect(result[1].allocations).to eq([alloc])
      end

      it "has a third overlap that matches the alloc end and initial end" do
        expect(result[2].start_date).to eq(alloc.end_date + 1.day)
        expect(result[2].end_date).to eq(initial.end_date)
        expect(result[2].allocations).to be_empty
      end
    end
  end
end
