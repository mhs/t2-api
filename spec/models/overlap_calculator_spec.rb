require 'rails_helper'
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
      let(:allocations) { [double(start_date: day(2), end_date: day(3), percent_allocated: 100, :"vacation?" => false)] }

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "with a single conflict" do
      let(:allocations) do
        [
          double(start_date: day(0), end_date: day(2), percent_allocated: 100, :"vacation?" => false),
          double(start_date: day(1), end_date: day(1), percent_allocated: 100, :"vacation?" => false),
          double(start_date: day(3), end_date: day(3), percent_allocated: 100, :"vacation?" => false)
        ]
      end

      it "returns one thing" do
        expect(result.size).to eq(1)
      end
    end

    context "with a partial-allocation not-really-a-conflict" do
      let(:allocations) do
        [
          double(start_date: day(0), end_date: day(3), percent_allocated: 50, :"vacation?" => false),
          double(start_date: day(0), end_date: day(2), percent_allocated: 25, :"vacation?" => false)
        ]
      end

      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "vacation conflicts with everything" do
      let(:allocations) do
        [
          double(start_date: day(0), end_date: day(0), percent_allocated: 50, :"vacation?" => true),
          double(start_date: day(0), end_date: day(1), percent_allocated: 50, :"vacation?" => false),
        ]
      end

      it "returns one thing" do
        expect(result.size).to eq(1)
      end
    end
  end

  describe "availabilities" do
    let(:result) { subject.availabilities }

    context "no allocations mean total availability" do
      let(:allocations) { [] }

      it "returns an availability for the entire time range" do
        expect(result.size).to eq(1)
        expect(result.first.start_date).to eq(start_date)
        expect(result.first.end_date).to eq(end_date)
      end
    end

    context "not available when allocated" do
      let(:allocations) { [double(start_date: day(0), end_date: day(2), percent_allocated: 100)] }

      it "returns an availability for the unallocated region" do
        expect(result.size).to eq(1)
        expect(result.first.start_date).to eq(day(3))
        expect(result.first.end_date).to eq(initial_overlap.end_date)
      end
    end

    context "partially available when partially allocated" do
      let(:allocations) { [double(start_date: day(0), end_date: day(2), percent_allocated: 75)] }

      it "returns two things" do
        expect(result.size).to eq(2)
      end

      it "returns a partial availability for the allocated region" do
        expect(result.first.start_date).to eq(initial_overlap.start_date)
        expect(result.first.end_date).to eq(day(2))
        expect(result.first.percent_allocated).to eq(25)
      end

      it "returns an availability for the unallocated region" do
        expect(result.second.start_date).to eq(day(3))
        expect(result.second.end_date).to eq(initial_overlap.end_date)
        expect(result.second.percent_allocated).to eq(100)
      end
    end
  end
end

