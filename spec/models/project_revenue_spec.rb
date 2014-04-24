require 'spec_helper'

describe "project revenue calculation" do

  let(:start_date) { Date.today.beginning_of_week }
  let(:end_date) { start_date + 4.days }

  let(:office) { FactoryGirl.create(:office) }
  let(:project) { FactoryGirl.create(:project, offices: [office]) }
  let(:person) { FactoryGirl.create(:person, office: office, role: 'Developer') }
  let!(:allocation) do
    FactoryGirl.create(:allocation, :billable,
                       start_date: start_date,
                       end_date: end_date,
                       project: project,
                       person: person)
  end

  let(:rate) { project.rate_for(person.role) }

  let(:revenue) { project.revenue_for(start_date: start_date, end_date: end_date) }

  context "a project allocated all week" do

    it "has five days of billable project time" do
      expect(revenue).to eq(5 * rate)
    end

    context "on an investment friday project" do
      before { project.investment_fridays = true; project.save! }

      it "has four days of billable project time" do
        expect(revenue).to eq(4 * rate)
      end
    end
  end

  context "a project allocated provisionally all week" do
    before { allocation.provisional = true; allocation.save! }
    context "when not including provisional allocations" do
      it "has no revenue" do
        expect(revenue).to eq(0.0)
      end
    end
  end

  context "a project with a developer who takes vacation" do
    let(:vacation_project) { FactoryGirl.create(:project, :vacation, offices: [office]) }
    let!(:vacation) do
      FactoryGirl.create(:allocation, :vacation,
                         start_date: start_date,
                         end_date: start_date,
                         project: vacation_project,
                         person: person)
    end

    it "has four days of billable project time" do
      expect(revenue).to eq(4 * rate)
    end

    context "on an investment friday project" do
      before { project.investment_fridays = true; project.save! }

      context "the vacation is on Friday" do
        before do
          vacation.start_date = end_date
          vacation.end_date = end_date
          vacation.save!
        end

        it "has four days of billable project time" do
          expect(revenue).to eq(4 * rate)
        end
      end

      context "the vacation is not on Friday" do
        it "has three days of billable project time" do
          expect(revenue).to eq(3 * rate)
        end
      end
    end
  end

  context "with company holidays" do
    let!(:holiday_project) { FactoryGirl.create(:project, :holiday, offices: [office]) }

    context "a single-day holiday" do
      let!(:festivus) { Holiday.declare("Festivus", [office], start_date) }

      it "has 4 days of billable project time" do
        expect(revenue).to eq(4 * rate)
      end

      context "on an investment friday project" do
        it "has 4 days of billable project time" do
          expect(revenue).to eq(4 * rate)
        end
      end
    end

    context "a two-day holiday" do
      let!(:festivus_eve) { Holiday.declare("Festivus", [office], start_date) }
      let!(:festivus) { Holiday.declare("Festivus", [office], start_date + 1.day) }

      it "has 3 days of billable project time" do
        expect(revenue).to eq(3 * rate)
      end

      context "on an investment friday project" do
        it "has 3 days of billable project time" do
          expect(revenue).to eq(3 * rate)
        end
      end
    end
  end
end
