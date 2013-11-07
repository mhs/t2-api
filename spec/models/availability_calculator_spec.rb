require 'spec_helper'
describe AvailabilityCalculator do

  let(:person) { FactoryGirl.create(:person) }
  let(:start_date) { Date.today.beginning_of_week }
  let(:end_date) { start_date + 4.days }
  let(:availability) { Availability.new(person_id: person.id, start_date: start_date, end_date: end_date) }
  let(:result) { AvailabilityCalculator.new(allocations, availability).availabilities }

  context "with no allocations" do
    let(:allocations) { [] }
    it "returns the initial availability" do
      result.should == [availability]
    end
  end

  context "with an existing allocation" do
    let(:alloc_start) { start_date }
    let(:alloc_end) { end_date }
    let(:allocations) { [double(start_date: alloc_start, end_date: alloc_end)] }

    context "with a single day allocation" do
      let(:middle_day) { start_date + 3.days }
      let(:allocations) do
        [
          double(start_date: start_date, end_date: middle_day - 1.day),
          double(start_date: middle_day, end_date: middle_day),
          double(start_date: middle_day + 1.day, end_date: end_date)
        ]
      end

      it "returns no availability" do
        result.should == []
      end
    end

    context "starting before and ending within the specified dates" do
      let(:alloc_start) { start_date - 1.day }
      let(:alloc_end) { start_date + 3.days }
      it "returns an availability starting on the allocation's end date" do
        result.should == [availability.similar(start_date: alloc_end + 1.day)]
      end
    end

    context "starting within and ending after the specified dates" do
      let(:alloc_start) { start_date + 1.day }
      let(:alloc_end) { end_date + 1.day }
      it "returns an availability ending on the allocation's start date" do
        result.should == [availability.similar(end_date: alloc_start - 1.day)]
      end
    end

    context "that falls entirely within the specified dates" do
      let(:alloc_start) { start_date + 1.day }
      let(:alloc_end) { end_date - 1.day }
      it "returns availabilites around the allocation" do
        result.first.should == availability.similar(start_date: start_date, end_date: alloc_start - 1.day)
        result.second.should == availability.similar(start_date: alloc_end + 1.day, end_date: end_date)
      end
    end

    context "that completely encompasses the specified dates" do
      let(:alloc_start) { start_date - 1.day }
      let(:alloc_end) { end_date + 1.day }
      it "should return an empty array " do
        result.should == []
      end
    end

    context "that falls outside the specified dates" do
      let(:alloc_start) { start_date - 2.weeks }
      let(:alloc_end) { start_date - 1.week }
      it "returns the initial availability" do
        result.should == [availability]
      end
    end

    context "many allocations" do
      context "that don't overlap" do
        let(:base_date) { start_date }
        let(:allocations) do
          [
            double(start_date: base_date+1.day, end_date: base_date+1.day),
            double(start_date: base_date+3.days, end_date: base_date+3.days)
          ]
        end

        it "returns the right things" do
          result.size.should == 3
        end
      end

      context "that overlap" do
        let(:base_date) { start_date }
        let(:allocations) do
          [
            double(start_date: base_date+1.day, end_date: base_date+3.days),
            double(start_date: base_date+2.days, end_date: base_date+3.days)
          ]
        end

        it "returns the right things" do
          result.size.should == 2
          result.first.should == availability.similar(end_date: base_date)
          result.second.should == availability.similar(start_date: base_date+4.days)
        end
      end
    end
  end
end
