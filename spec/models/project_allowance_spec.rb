require 'spec_helper'

describe ProjectAllowance do

  context "calculating remaining hours allowance" do
    let(:vacation)   { FactoryGirl.create(:project, :vacation) }
    let(:person)     { FactoryGirl.create(:person, allocation_ids: [caribbean_vacation.id, italy_vacation.id]) }
    let(:vacation_allowance) { FactoryGirl.create(:project_allowance, person: person, project: vacation, hours: 160) }
    let(:caribbean_vacation) { FactoryGirl.create(:allocation, project: vacation, start_date: Date.parse('04-09-2013'), end_date: Date.parse('05-09-2013')) }
    let(:italy_vacation) { FactoryGirl.create(:allocation, project: vacation, start_date: Date.parse('09-09-2013'), end_date: Date.parse('13-09-2013')) }

    it 'counts its available hours' do
      expect(vacation_allowance.available).to eq(104)
    end

    it 'counts its used hours' do
      expect(vacation_allowance.used).to eq(56)
    end
  end
end

