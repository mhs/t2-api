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

  let(:revenue_items) { RevenueCalculator.new(person: person, start_date: start_date, end_date: end_date).revenue_items }

  context "a project allocated all week" do

    it "has five days of billable project time" do
      expect(revenue_items.length).to eq(5)
    end

    context "on an investment friday project" do
      before { project.investment_fridays = true; project.save! }

      it "has four days of billable project time" do
        expect(revenue_items.length).to eq(5)
        expect(billing_items.length).to eq(4)
      end
    end
  end

  context "a project allocated speculatively all week" do
    before { allocation.likelihood = '90% Likely'; allocation.save! }
    context "when not including speculative allocations" do
      it "has no revenue" do
        expect(speculative_items.length).to eq(5)
      end
    end
  end

  context "with company holidays" do
    let!(:holiday_project) { FactoryGirl.create(:project, :holiday, offices: [office]) }

    context "a single-day holiday" do
      let!(:festivus) { Holiday.declare("Festivus", [office], start_date) }

      it "has 4 days of billable project time" do
        expect(billing_items.length).to eq(4)
      end

      context "on an investment friday project" do
        it "has 4 days of billable project time" do
          expect(billing_items.length).to eq(4)
        end
      end
    end

    context "a two-day holiday" do
      let!(:festivus_eve) { Holiday.declare("Festivus", [office], start_date) }
      let!(:festivus) { Holiday.declare("Festivus", [office], start_date + 1.day) }

      it "has 3 days of billable project time" do
        expect(billing_items.length).to eq(3)
      end

      context "on an investment friday project" do
        it "has 3 days of billable project time" do
          expect(billing_items.length).to eq(3)
        end
      end
    end
  end

  def billing_items
    revenue_items.select { |i| i.amount > 0 }
  end

  def speculative_items
    revenue_items.select { |i| i.speculative? }
  end
end
