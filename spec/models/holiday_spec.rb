require 'spec_helper'

describe Holiday do
  before do
    Project.create! do |p|
      p.name = "Office Holiday"
      p.holiday = true
      p.vacation = true
    end
  end

  let(:person) do
    FactoryGirl.create(:person)
  end

  let(:office) do
    person.office
  end

  let! (:holiday) do
    Holiday.declare("Hug a Vegan", [office], Date.today, Date.today)
  end

  describe "#declare" do
    context "allocation" do
      let(:allocation) do
        office.people.first.allocations.first
      end

      it "allocates vacation start date" do
        expect(allocation.start_date).to eql(Date.today)
      end

      it "allocates vacation end date" do
        expect(allocation.end_date).to eql(Date.today)
      end

      it "inserts a note with the holiday name" do
        expect(allocation.notes).to eql("Hug a Vegan")
      end
    end

    it "adds a holiday to an office" do
      expect(office.holidays.first).to eql(holiday)
    end
  end

  describe ".add_person" do
    let :new_person do
      FactoryGirl.create(:person)
    end


    before do
      Holiday.first.add_person(new_person)
    end

    it "allocates vacation starting at the holiday start date" do
      expect(new_person.allocations.first.start_date).to eql(Date.today)
    end

    it "allocates vacation ending at the holiday end date" do
      expect(new_person.allocations.first.end_date).to eql(Date.today)
    end

    it "inserts a note with the holiday name" do
      expect(new_person.allocations.first.notes).to eql("Hug a Vegan")
    end
  end
end
