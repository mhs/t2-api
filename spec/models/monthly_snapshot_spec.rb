require 'rails_helper'
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

  describe 'recalculate' do

    let(:snapshot) { MonthlySnapshot.on_date!(Date.today) }

    it 'resets values before calculating' do
      billable_days = snapshot.billable_days
      assignable_days = snapshot.assignable_days
      billing_days = snapshot.billing_days

      snapshot.recalculate!
      snapshot.reload

      expect(snapshot.billing_days).to eq(billing_days)
      expect(snapshot.billable_days).to eq(billable_days)
      expect(snapshot.assignable_days).to eq(assignable_days)
    end

  end
end
