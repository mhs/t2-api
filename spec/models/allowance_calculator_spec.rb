require 'spec_helper'

describe AllowanceCalculator do
  let(:person) { FactoryGirl.create :person, allocation_ids: [allocation.id], office_id: office.id }
  let(:project) { FactoryGirl.create :project }
  let(:allocation) { FactoryGirl.create :allocation, start_date: Date.parse('03-09-2013'), end_date: Date.parse('05-09-2013'), project_id: project.id }
  let(:office) { FactoryGirl.create :office }
  let!(:project_office) { FactoryGirl.create :project_office, allowance: 80, project: project, office_id: office.id }

  context 'calculating hours' do
    it 'should calculate the total hours spent on a project' do
      ac = AllowanceCalculator.new(person, project)
      expect(ac.hours_spent).to eq(24)
    end
  end

  context 'validating a project allowance' do
    let(:ac) { AllowanceCalculator.new(person, project) }

    it 'should figure out if an allocation exceeds the project allowance' do
      expect(ac.exceeds_allowance? 80).to be_true
    end

    it 'should figure out if an allocation does not exceed project allowance' do
      expect(ac.exceeds_allowance? 10).to be_false
    end
  end
end
