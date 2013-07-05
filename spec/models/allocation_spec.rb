require 'spec_helper'

describe Allocation do
  describe '.today' do
    it 'includes an allocation that spans today' do
      allocation = FactoryGirl.create(:allocation, start_date: 1.week.ago, end_date: 1.week.from_now)
      Allocation.today.should include(allocation)
    end
    it 'includes an allocation that starts today' do
      allocation = FactoryGirl.create(:allocation, start_date: Date.today, end_date: 1.week.from_now)
      Allocation.today.should include(allocation)
    end
    it 'includes an allocation that ends today' do
      allocation = FactoryGirl.create(:allocation, start_date: 1.week.ago, end_date: Date.today)
      Allocation.today.should include(allocation)
    end
    it 'does not include allocations that ended in the past' do
      allocation = FactoryGirl.create(:allocation, start_date: 2.weeks.ago, end_date: 1.week.ago)
      Allocation.today.should_not include(allocation)
    end
    it 'does not include allocations that start in the future' do
      allocation = FactoryGirl.create(:allocation, start_date: 1.week.from_now, end_date: 2.weeks.from_now)
      Allocation.today.should_not include(allocation)
    end
    it 'does not include allocations for deleted projects' do
      allocation = FactoryGirl.create(:allocation, start_date: 1.week.ago, end_date: 1.week.from_now)
      allocation.project.destroy
      Allocation.today.should_not include(allocation)
    end
  end

  describe '.assignable' do
    it 'includes an allocation on billable project' do
      project = FactoryGirl.create(:project)
      allocation = FactoryGirl.create(:allocation, :active, project: project)
      Allocation.assignable.should include(allocation)
    end
    it 'does not include an allocation on a vacation project' do
      project = FactoryGirl.create(:project, :vacation)
      allocation = FactoryGirl.create(:allocation, :active, project: project)
      Allocation.assignable.should_not include(allocation)
    end
    it 'does not include an allocation on a project that has been deleted' do
      project = FactoryGirl.create(:project)
      allocation = FactoryGirl.create(:allocation, :active, project: project)
      project.destroy
      Allocation.assignable.should_not include(allocation)
    end
  end

  describe '.unassignable' do
    it 'does not include an allocation on billable project' do
      project = FactoryGirl.create(:project, :billable)
      allocation = FactoryGirl.create(:allocation, :active, project: project)
      Allocation.unassignable.should_not include(allocation)
    end
    it 'does include an allocation on a vacation project' do
      project = FactoryGirl.create(:project, :vacation)
      allocation = FactoryGirl.create(:allocation, :active, project: project)
      Allocation.unassignable.should include(allocation)
    end
    it 'does not include an allocation on a project that has been deleted' do
      project = FactoryGirl.create(:project, :vacation)
      allocation = FactoryGirl.create(:allocation, :active, project: project)
      project.destroy
      Allocation.unassignable.should_not include(allocation)
    end
  end
end
