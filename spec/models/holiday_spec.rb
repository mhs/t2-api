require 'rails_helper'

describe Holiday do
  before do
    FactoryGirl.create(:project, :holiday)
  end

  let! (:office) do
    FactoryGirl.create(:office)
  end

  let! (:person) do
    FactoryGirl.create(:person, office: office)
  end

  let! (:holiday) do
    Holiday.declare("Hug a Vegan", [office], Date.today, Date.today)
  end
  
  describe ".allocations" do
    before(:each) do
      joe = FactoryGirl.create(:person, office: columbus, start_date: 1.week.ago)
      sally = FactoryGirl.create(:person, office: columbus, start_date: 1.week.ago)
    end

    let(:columbus) do
      Office.first
    end

    let(:shutdown_start) do
      1.week.from_now.to_date
    end

    let(:shutdown_end) do
      2.weeks.from_now.to_date
    end

    let(:office_shutdown) do
      Holiday.declare("Office Shutdown", [columbus], shutdown_start, shutdown_end)
    end

    let(:office_shutdown_allocations) do
      office_shutdown.allocations
    end

    it "should only include allocations for the holiday project" do
      project = office_shutdown_allocations.first.project
      project.holiday.should be_truthy
    end

    it "should include allocations for everyone in the office" do
      office_shutdown_allocations.should have_at_least(2).items
    end

    it "should include allocations that start on the right date" do
      office_shutdown_allocations.first.start_date.should eql(shutdown_start)
    end

    it "should include allocations that end on the right date" do
      office_shutdown_allocations.first.end_date.should eql(shutdown_end)
    end
  end

  it "destroys allocations when it is destroyed" do
    holiday_project = Project.find_by(holiday: true)
    Allocation.where(project: holiday_project).should_not be_empty
    holiday.destroy
    Allocation.where(project: holiday_project).should be_empty
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
