require 'spec_helper'
describe OverlapCalculator do

  let(:person) { double(id: 42) }
  let(:start_date) { Date.today.beginning_of_week }
  let(:end_date) { day(14) }
  let(:initial_overlap) { Overlap.new(person: person, start_date: start_date, end_date: end_date) }
  let(:result) { OverlapCalculator.new(initial_overlap, allocations).overlaps }

  def day(offset)
    start_date + offset.days
  end

  context "with no allocations" do
    let(:allocations) { [] }
    it "returns the initial overlap" do
      expect(result.size).to eq(1)
      expect(result.first).to eq(initial_overlap)
    end
  end

  context "with one allocation" do
    let(:alloc_start) { start_date }
    let(:alloc_end) { day(4) }
    let(:allocations) do
      [
        double(start_date: alloc_start, end_date: alloc_end, percent_allocated: 100)
      ]
    end

    it "returns two segments" do
      expect(result.size).to eq(2)
    end

    it "has the first segment fully utilized" do
      expect(result[0].percent_allocated).to eq(100)
      expect(result[0].end_date).to eq(alloc_end)
    end

    it "has the second segment un-utilized" do
      expect(result[1].percent_allocated).to eq(0)
      expect(result[1].start_date).to eq(alloc_end + 1.day)
    end

    it "records the allocations that affect each segment" do
      expect(result[0].allocations).to eq(allocations)
      expect(result[1].allocations).to eq([])
    end
  end

  context "with two overlapping allocations" do
    context "at the start" do
      # |--------|
      # |-----|
      let(:allocations) do
        [
          double(start_date: day(0), end_date: day(5), percent_allocated: 100),
          double(start_date: day(0), end_date: day(3), percent_allocated: 100)
        ]
      end

      it "returns three segments" do
        expect(result.size).to eq(3)
      end

      it "has a conflict in the first segment" do
        expect(result[0].allocations.size).to eq(2)
      end

      it "does not have a conflict in the second segment" do
        expect(result[1].allocations.size).to eq(1)
      end
    end

    context "at the endr" do
      # |--------|
      #    |-----|
      let(:allocations) do
        [
          double(start_date: day(10), end_date: day(14), percent_allocated: 100),
          double(start_date: day(12), end_date: day(14), percent_allocated: 100)
        ]
      end

      it "returns three segments" do
        expect(result.size).to eq(3)
      end

      it "has a conflict in the third segment" do
        expect(result[2].allocations.size).to eq(2)
      end

      it "does not have a conflict in the second segment" do
        expect(result[1].allocations.size).to eq(1)
      end
    end
  end

end

