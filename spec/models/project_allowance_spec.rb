require 'spec_helper'

describe ProjectAllowance do

  context "calculating remaining hours allowance" do
    let(:vacation)   { FactoryGirl.create(:project, :vacation) }
    let(:person)     { FactoryGirl.create(:person, allocation_ids: [caribbean_vacation.id, italy_vacation.id]) }
    let(:vacation_allowance) { FactoryGirl.create(:project_allowance, person: person, project: vacation, hours: 160) }
    let(:start_date) { [Date.today - 1.month - 10.days, Date.today.beginning_of_year].max }
    let(:caribbean_vacation) { FactoryGirl.create(:allocation, project: vacation, start_date: start_date, end_date: start_date + 4.days) }
    let(:italy_vacation) { FactoryGirl.create(:allocation, project: vacation, start_date: start_date + 1.month, end_date: start_date + 1.month + 5.days) }

    it 'counts its available hours' do
      expect(vacation_allowance.available).to eq(104)
    end

    it 'counts its used hours' do
      expect(vacation_allowance.used).to eq(56)
    end
  end
end

