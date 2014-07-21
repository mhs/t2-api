require 'spec_helper'

describe RevenueItem do

  # tunable params
  let(:investment_fridays) { false }
  let(:billable) { true }
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
      billable: billable,
      person: person
    })
  end
  let(:normal_rate) { project.rate_for(person.role) }

  let(:revenue_item) do
    RevenueItem.for_allocation!(allocation,
                                day: day,
                                vacation_percentage: vacation_percentage,
                                holiday_in_week: holiday_in_week)
  end
  let(:revenue) do
    revenue_item.amount
  end

  describe "#for_allocation!" do

    context "creating a new revenue item" do
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

        context "in a non-billable allocation" do
          let(:billable) { false }

          it "gets no revenue" do
            expect(revenue).to eq(0.0)
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

    context "updating an existing revenue item" do

      context "its underlying allocation changes" do

        context "future allocation" do
          let(:day) { (Date.today + 1.week).beginning_of_week }

          it "updates the existing revenue item" do
            old_item = revenue_item
            allocation.update(percent_allocated: 50)
            new_item = RevenueItem.for_allocation!(allocation,
                                                   day: day,
                                                   vacation_percentage: vacation_percentage,
                                                   holiday_in_week: holiday_in_week)
            expect(RevenueItem.count).to eq(1)
            expect(new_item.id).to eq(revenue_item.id)
            expect(new_item.amount).to eq(revenue_item.amount / 2.0)
          end
        end

        context "past allocation" do
          let(:day) { (Date.today - 1.month).beginning_of_week }

          it "noops" do
            old_item = revenue_item
            allocation.update(percent_allocated: 50)
            new_item = RevenueItem.for_allocation!(allocation,
                                                   day: day,
                                                   vacation_percentage: vacation_percentage,
                                                   holiday_in_week: holiday_in_week)
            expect(RevenueItem.count).to eq(1)
            expect(new_item.id).to eq(revenue_item.id)
            expect(new_item.amount).to eq(revenue_item.amount)
          end
        end
      end
    end
  end
end
