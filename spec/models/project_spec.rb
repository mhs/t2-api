require 'spec_helper'

describe Project do
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
end
