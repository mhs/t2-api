require 'spec_helper'
require 'date_range_helper'

describe MonthlySnapshot do

  include DateRangeHelper

  let(:employee) {FactoryGirl.create(:person, :current)}
  let(:start_date) { Date.today.beginning_of_month.advance(days: 7).beginning_of_week }
  let(:end_date) { start_date + 5.days }

  before(:each) do
    FactoryGirl.create(:allocation, :active, :billable,
                       person: employee,
                       start_date: start_date,
                       end_date: end_date)
  end

  describe '.on_date!' do
    let(:snapshot) { MonthlySnapshot.on_date!(Date.today) }

    let(:week_days_in_month) { week_days.size }

    it 'should count assignable days' do
      snapshot.assignable_days.should eq(week_days_in_month)
    end

    it 'should count billing days' do
      snapshot.billing_days.should eq(5)
    end
  end
end
