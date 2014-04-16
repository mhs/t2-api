require 'spec_helper'
describe OverlapCalculator do

  let(:person) { double(id: 42, percent_billable: 100) }
  let(:start_date) { Date.today.beginning_of_week }
  let(:end_date) { day(14) }
  let(:initial_overlap) { Overlap.new(person: person, start_date: start_date, end_date: end_date) }
  subject { OverlapCalculator.new(initial_overlap, allocations) }

  def day(offset)
    start_date + offset.days
  end

  describe "overlaps" do
    let(:result) { subject.overlaps }

    context "with three overlapping allocations" do
      let(:allocations) do
        #    |-------------|
        # 1:     |---|
        # 2:       |---|
        # 3:      |-----|
        [
          double(start_date: day(4), end_date: day(8), percent_allocated: 100),
          double(start_date: day(6), end_date: day(10), percent_allocated: 100),
          double(start_date: day(5), end_date: day(11), percent_allocated: 100)
        ]
      end

      # |---|||-|-||--|
      it "returns 7 regions" do
        expect(result.size).to eq(7)
      end

      it "returns the correct number of allocations in each region" do
        expect(result.map { |ol| ol.allocations.size }).to eq([0,1,2,3,2,1,0])
      end
    end
  end

  describe "conflicts" do
    let(:result) { subject.conflicts }

    context "with no conflicts" do
      let(:allocations) { [double(start_date: day(2), end_date: day(3), percent_allocated: 100, vacation: false)] }

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "with a single conflict" do
      let(:allocations) do
        [
          double(start_date: day(0), end_date: day(2), percent_allocated: 100, vacation: false),
          double(start_date: day(1), end_date: day(1), percent_allocated: 100, vacation: false),
          double(start_date: day(3), end_date: day(3), percent_allocated: 100, vacation: false)
        ]
      end

      it "returns one thing" do
        expect(result.size).to eq(1)
      end
    end

    context "with a partial-allocation not-really-a-conflict" do
      let(:allocations) do
        [
          double(start_date: day(0), end_date: day(3), percent_allocated: 50, vacation: false),
          double(start_date: day(0), end_date: day(2), percent_allocated: 25, vacation: false)
        ]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "vacation conflicts with everything" do
      let(:allocations) do
        [
          double(start_date: day(0), end_date: day(0), percent_allocated: 50, vacation: true),
          double(start_date: day(0), end_date: day(1), percent_allocated: 50, vacation: false),
        ]
      end

      it "returns one thing" do
        expect(result.size).to eq(1)
      end
    end
  end
end

