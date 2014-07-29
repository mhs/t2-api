require 'allocations_in_dates'
require 'spec_helper'

describe AllocationsInDates do

  describe "#allocations_between" do
    let(:bob){ FactoryGirl.create(:person)}
    let(:alice){ FactoryGirl.create(:person)}
    let(:project){FactoryGirl.create(:project)}

    let(:subject){AllocationsInDates.new(project, bob)}

    it "picks up an allocation within a range" do
      project.allocations.create!(person: bob, start_date: '2014-07-22', end_date: '2014-07-24')

      expect(subject.allocations_between('2014-07-21', '2014-07-25')).to(eq(3))
      project.allocations.create!(person: bob, start_date: '2014-07-21', end_date: '2014-07-21')
      expect(subject.allocations_between('2014-07-21', '2014-07-25')).to(eq(4))
    end

    it "handles dates and strings" do

      project.allocations.create!(person: bob, start_date: '2014-07-22', end_date: '2014-07-24')

      expect(subject.allocations_between(Date.parse('2014-07-21'), Date.parse('2014-07-25'))).to(eq(3))
    end

    it "only picks up allocations for the relevant person" do
      project.allocations.create!(person: bob, start_date: '2014-07-22', end_date: '2014-07-24')
      project.allocations.create!(person: alice, start_date: '2014-07-22', end_date: '2014-07-24')

      expect(subject.allocations_between('2014-07-21', '2014-07-25')).to(eq(3))
    end

    it "ignores weekend allocations" do
      project.allocations.create!(person: bob, start_date: '2014-07-18', end_date: '2014-07-24')
      expect(subject.allocations_between('2014-07-17', '2014-07-25')).to(eq(5))
    end

    it "only counts allocations within the date range" do
      project.allocations.create!(person: bob, start_date: '2014-07-21', end_date: '2014-07-22')
      project.allocations.create!(person: bob, start_date: '2014-07-25', end_date: '2014-07-25')

      expect(subject.allocations_between('2014-07-23', '2014-07-24')).to(eq(0))
    end


    it "counts overlapping days in an allocation that overlaps the beginning of the range" do
      project.allocations.create!(person: bob, start_date: '2014-07-21', end_date: '2014-07-23')

      expect(subject.allocations_between('2014-07-22', '2014-07-24')).to(eq(2))
    end

    it "counts overlapping days in an allocation that overlaps the end of the range" do
      project.allocations.create!(person: bob, start_date: '2014-07-23', end_date: '2014-07-25')

      expect(subject.allocations_between('2014-07-21', '2014-07-24')).to(eq(2))
    end

  end
end
