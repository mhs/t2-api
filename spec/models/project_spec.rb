require 'spec_helper'

describe Project do
  describe "initialize" do

    context 'with no rates' do
      let(:project) { Project.new }
      it 'has appropriate default rates' do
        expect(project.rates['Developer']).to eq(7000)
        expect(project.rates['Designer']).to eq(7000)
        expect(project.rates['Product Manager']).to eq(7000)
        expect(project.rates['Principal']).to eq(14000)
      end
    end

    context 'with rates' do
      let(:project) { Project.new(rates: {'Developer' => 39000}) }
      it 'allows for overriding a specific rate(s)' do
        expect(project.rates['Developer']).to eq(39000)
        expect(project.rates['Designer']).to eq(7000)
        expect(project.rates['Product Manager']).to eq(7000)
        expect(project.rates['Principal']).to eq(14000)
      end
    end
  end

  describe "rate_for" do
    let(:project) { FactoryGirl.create(:project, :billable, rates: { 'Developer' => '2000' }) }

    it 'divides the week rate by 5' do
      expect(project.rate_for('Developer')).to eq(400)
    end

    it 'divides the week rate by 4 if investment fridays' do
      project.investment_fridays = true
      expect(project.rate_for('Developer')).to eq(500)
    end
  end

  describe '.unassignable' do
    it 'true if marked as a vacation project' do
      project = FactoryGirl.create(:project, vacation: true)
      Project.assignable.should include(project)
    end
    it 'false by default' do
      project = FactoryGirl.create(:project)
      Project.assignable.should_not include(project)
    end
  end

  describe '.allocations/.employed_allocations' do
    let(:project) { FactoryGirl.create(:project) }
    let(:person_past) { FactoryGirl.create(:person, :past) }
    let!(:active_allcoation) { FactoryGirl.create(:allocation, :active, project: project) }
    let!(:allocation_unemployed) { FactoryGirl.create(:allocation, :active, project: project, person: person_past) }

    let(:start_date) { Date.today }
    let(:end_date) { Date.today + 1.week }

    it 'has all allocations' do
      Project.within_date_range(start_date, end_date) do
        expect(project.allocations.count).to eql(2)
      end
    end

    it 'has only employed allocations' do
      Project.within_date_range(start_date, end_date) do
        binding.pry
        expect(project.employed_allocations.count).to eql(1)
      end
    end
  end

end
