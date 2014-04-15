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

  context "three overlapping allocations" do
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

