require 'spec_helper'

describe RevenueItem do

  # tunable params
  let(:investment_fridays) { false }
  let(:percent_allocated) { 100 }
  let(:provisional) { false }
  let(:holiday_in_week) { false }
  let(:vacation_percentage) { 0 }
  let(:day) { Date.today.beginning_of_week }

  let(:office) { FactoryGirl.create(:office) }
  let(:project) do
    FactoryGirl.create(:project, investment_fridays: investment_fridays, offices: [office])
  end

  let(:person) { FactoryGirl.create(:person, role: 'Developer', office: office) }
  let(:allocation) do
    FactoryGirl.create(:allocation, {
      percent_allocated: percent_allocated,
      provisional: provisional,
      project: project,
      person: person
    })
  end
  let(:normal_rate) { project.rate_for(person.role) }

  let(:revenue) do
    RevenueItem.for_allocation(allocation,
                               day: day,
                               vacation_percentage: vacation_percentage,
                               holiday_in_week: holiday_in_week).amount
  end

  describe "create_from_overlaps!" do

    context "a person assigned to one project" do

      context "on a regular day" do
        it "gets one day of revenue" do
          expect(revenue).to eq(normal_rate)
        end
      end

      context "on investment friday" do
        let(:investment_fridays) { true }
        let(:day) { Date.today.beginning_of_week + 4.days }

        it "gets no revenue" do
          expect(revenue).to eq(0.0)
        end

        context "when there's a holiday that week" do
          let(:holiday_in_week) { true }

          it "gets one day of revenue" do
            expect(revenue).to eq(normal_rate)
          end
        end
      end

      context "who is on vacation" do
        let(:vacation_percentage) { 100 }

        it "gets no revenue" do
          expect(revenue).to eq(0.0)
        end

        context "for a half-day" do
          let(:vacation_percentage) { 50 }
          it "gets half revenue" do
            expect(revenue).to eq(normal_rate / 2)
          end
        end
      end
    end
  end
end
