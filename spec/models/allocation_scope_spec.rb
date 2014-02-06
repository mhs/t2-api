require 'spec_helper'
describe AllocationScope do
  let(:date) { Date.today }
  let(:office) { FactoryGirl.create(:office) }
  let(:project) { FactoryGirl.create(:project, vacation: false, billable: true, offices: [office]) }
  let(:vacation_project) { FactoryGirl.create(:project, vacation: true, billable: false, offices: [office]) }
  let(:allocation_relation) { Allocation.by_office(nil).on_date(date).includes(:person) }
  let(:calc) { AllocationScope.new allocation_relation }
  let(:developer) { FactoryGirl.create(:person) }
  let(:pm) { FactoryGirl.create(:person, percent_billable: 75) }
  let(:staff) { FactoryGirl.create(:person, percent_billable: 0) }

  describe ".billing" do
    let(:result) { calc.billing }

    context "a developer on vacation" do
      let!(:vacation) { vacation_for(developer, percent_allocated: 100) }
      let!(:allocation) { allocation_for(developer, percent_allocated: 100) }

      it "doesn't show the developer" do
        expect(result.size).to eq(0)
      end
    end

    context "a developer on a half-day" do
      let!(:vacation) { vacation_for(developer, percent_allocated: 50) }
      let!(:allocation) { allocation_for(developer, percent_allocated: 100) }

      it "shows the developer as 50% billing" do
        expect(result.size).to eq(1)
        expect(result[developer]).to eq(50)
      end
    end

    context "a PM on vacation" do
      let!(:vacation) { vacation_for(pm, percent_allocated: 100) }
      let!(:allocation) { allocation_for(pm, percent_allocated: 75) }

      it "does not show the PM" do
        expect(result.size).to eq(0)
      end
    end

    context "a PM on a half-day" do
      let!(:vacation) { vacation_for(pm, percent_allocated: 50) }
      let!(:allocation) { allocation_for(pm, percent_allocated: 75) }

      it "shows the PM as 37% billing" do
        expect(result.size).to eq(1)
        expect(result[pm]).to eq(37)
      end
    end

    context "staff assigned to billable work on vacation" do
      let!(:vacation) { vacation_for(staff, percent_allocated: 100) }
      let!(:allocation) { allocation_for(staff, percent_allocated: 100) }

      it "does not show the staff" do
        expect(result.size).to eq(0)
      end
    end

    context "staff assigned to billable work on a half-day" do
      let!(:vacation) { vacation_for(staff, percent_allocated: 50) }
      let!(:allocation) { allocation_for(staff, percent_allocated: 100) }

      it "shows the staff" do
        expect(result.size).to eq(1)
        expect(result[staff]).to eq(50)
      end
    end
  end

  describe ".unassignable" do
    let(:result) { calc.unassignable }

    context "a developer on vacation" do
      let!(:allocation) { vacation_for(developer, percent_allocated: 100) }

      it "shows the developer as 100% unassignable" do
        expect(result.size).to eq(1)
        expect(result[developer]).to eq(100)
      end
    end

    context "a developer on a half-day" do
      let!(:allocation) { vacation_for(developer, percent_allocated: 50) }

      it "shows the developer as 50% unassignable" do
        expect(result.size).to eq(1)
        expect(result[developer]).to eq(50)
      end
    end

    context "a PM on vacation" do
      let!(:allocation) { vacation_for(pm, percent_allocated: 100) }

      it "shows the PM as 75% unassignable" do
        expect(result.size).to eq(1)
        expect(result[pm]).to eq(75)
      end
    end

    context "a PM on a half-day" do
      let!(:allocation) { vacation_for(pm, percent_allocated: 50) }

      it "shows the PM as 37% unassignable" do
        expect(result.size).to eq(1)
        expect(result[pm]).to eq(37)
      end
    end

    context "staff on vacation" do
      let!(:allocation) { vacation_for(staff, percent_allocated: 100) }

      it "does not show the staff" do
        expect(result.size).to eq(0)
      end
    end

    context "staff on a half-day" do
      let!(:allocation) { vacation_for(staff, percent_allocated: 50) }

      it "does not show the staff" do
        expect(result.size).to eq(0)
      end
    end
  end

  # CORNER CASES:
  #  * double-booking on vacations?

  def allocation_for(person, options={})
    FactoryGirl.create(:allocation, { person: person, project: project, binding: true, billable: true }.merge(options))
  end

  def vacation_for(person, options={})
    FactoryGirl.create(:allocation, { person: person, project: vacation_project, binding: true, billable: false }.merge(options))
  end

end
