require 'spec_helper'
describe Availability do

  let(:person) { FactoryGirl.create(:person) }
  let(:start_date) { Date.today }
  let(:end_date) { Date.today + 1.week }
  describe ".available_dates" do
    let(:dates) { Availability.new(person_id: person.id, start_date: start_date, end_date: end_date).available_dates }
    context "the person isn't allocated during the specified dates" do
      it "returns the specified dates" do
      end
    end

    context "the person is allocated during the specified dates" do
      let(:project) { FactoryGirl.create(:project, :billable) }
      let(:allocation) { FactoryGirl.create(:allocation, :active, project: project, person: person) }
      it "returns date ranges for any times that the person isn't allocated" do

      end
    end
  end

  describe ".weekend?" do
    let(:availability) { Availability.new(person_id: person.id, start_date: start_date, end_date: end_date) }

    context "with weekend-only allocations" do
      let(:start_date) { Date.today.beginning_of_week + 5.days } # Saturday
      let(:end_date) { start_date + 1.day } # Sunday

      it "is true" do
        expect(availability.weekend?).to eq(true)
      end
    end

    context "for weekday allocations that overlap with a weekend" do
      let(:start_date) { Date.today.beginning_of_week } # Monday
      let(:end_date) { start_date + 1.day } # Sunday

      it "is false" do
        expect(availability.weekend?).to eq(false)
      end
    end
  end
end

