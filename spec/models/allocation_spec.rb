require 'spec_helper'

describe Allocation do
  let(:current_user) { FactoryGirl.create(:user) }
  let(:allocation) { FactoryGirl.create(:allocation) }

  it 'should not be valid with an end date before the start date' do
    FactoryGirl.build(:allocation, start_date: Date.today, end_date: 2.days.ago).should_not be_valid
  end

  it 'should be valid without a creator' do
    FactoryGirl.build(:allocation, creator: nil).should be_valid
  end
end


describe "by_office Scope" do
  let(:office_a_person) { FactoryGirl.create(:person) }
  let(:office_b_person) { FactoryGirl.create(:person) }
  let(:project) { FactoryGirl.create(:project, offices: [office_a_person.office, office_b_person.office]) }

  before do
    @office_a_allocation = FactoryGirl.create(:allocation, project: project, person: office_a_person)
    @office_b_allocation = FactoryGirl.create(:allocation, project: project, person: office_b_person)
  end

  it 'should be able to fetch Allocations for giveno Office' do
    Allocation.by_office(@office_a_allocation.office).count.should eql(1)
    Allocation.by_office(@office_a_allocation.office).should include(@office_a_allocation)
    Allocation.by_office(@office_b_allocation.office).count.should eql(1)
    Allocation.by_office(@office_b_allocation.office).should include(@office_b_allocation)
  end

  it 'should return all allocations if office is nil' do
    Allocation.by_office(nil).to_a.should eql(Allocation.all.to_a)
  end
end

describe "starting_soon Scope" do

  it 'should include allocations starting bewteen today and 2 days from now' do
    allocation = FactoryGirl.create(:allocation, start_date: Date.today, end_date: 2.days.from_now)
    Allocation.starting_soon.should include(allocation)
  end

  it 'should include allocations starting bewteen today and 2 days from now' do
    allocation = FactoryGirl.create(:allocation, start_date: 2.days.from_now, end_date: 3.days.from_now)
    Allocation.starting_soon.should include(allocation)
  end

  it 'should not include allocations started before today' do
    allocation = FactoryGirl.create(:allocation, start_date: 1.week.ago, end_date: 2.days.from_now)
    Allocation.starting_soon.should_not include(allocation)
  end

  it 'should not include allocations starting further then 2 days from today' do
    allocation = FactoryGirl.create(:allocation, start_date: 3.days.from_now, end_date: 5.days.from_now)
    Allocation.starting_soon.should_not include(allocation)
  end
end

describe '.on_date' do
  let(:date) { Date.today }

  it 'includes an allocation that spans today' do
    allocation = FactoryGirl.create(:allocation, start_date: 1.week.ago, end_date: 1.week.from_now)
    Allocation.on_date(date).should include(allocation)
  end
  it 'includes an allocation that starts today' do
    allocation = FactoryGirl.create(:allocation, start_date: Date.today, end_date: 1.week.from_now)
    Allocation.on_date(date).should include(allocation)
  end
  it 'includes an allocation that ends today' do
    allocation = FactoryGirl.create(:allocation, start_date: 1.week.ago, end_date: Date.today)
    Allocation.on_date(date).should include(allocation)
  end
  it 'does not include allocations that ended in the past' do
    allocation = FactoryGirl.create(:allocation, start_date: 2.weeks.ago, end_date: 1.week.ago)
    Allocation.on_date(date).should_not include(allocation)
  end
  it 'does not include allocations that start in the future' do
    allocation = FactoryGirl.create(:allocation, start_date: 1.week.from_now, end_date: 2.weeks.from_now)
    Allocation.on_date(date).should_not include(allocation)
  end
  it 'does not include allocations for deleted projects' do
    allocation = FactoryGirl.create(:allocation, start_date: 1.week.ago, end_date: 1.week.from_now)
    allocation.project.destroy
    Allocation.on_date(date).should_not include(allocation)
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

describe '.between' do
  let(:start_date) {1.month.ago}
  let(:end_date) {1.month.from_now}

  it 'includes allocations falling on the range boundaries' do
    allocation = FactoryGirl.create(:allocation, start_date: start_date, end_date: end_date)
    Allocation.between(start_date, end_date).should include(allocation)
  end

  it 'includes allocations inside the range boundaries' do
    allocation = FactoryGirl.create(:allocation, start_date: start_date + 1.day, end_date: end_date - 1.day)
    Allocation.between(start_date, end_date).should include(allocation)
  end

  it "does not include allocations starting before the range boundary" do
    allocation = FactoryGirl.create(:allocation, start_date: start_date - 1.day, end_date: end_date)
    Allocation.between(start_date, end_date).should_not include(allocation)
  end

  it "does not include allocations ending after the range boundary" do
    allocation = FactoryGirl.create(:allocation, start_date: start_date, end_date: end_date + 1.day)
    Allocation.between(start_date, end_date).should_not include(allocation)
  end
end

describe '.this_year' do
  let(:base_date) { [Date.today - 1.month, Date.today.beginning_of_year].max + 1.month }
  let(:start_date) { base_date - 1.month }
  let(:end_date) { [base_date + 1.month, Date.today.end_of_year].min }
  let(:start_of_year) { base_date.beginning_of_year }
  let(:end_of_year) { base_date.end_of_year }

  it 'includes allocations falling within this year' do
    allocation = FactoryGirl.create(:allocation, start_date: start_date, end_date: end_date)
    Allocation.this_year.should include(allocation)
  end

  it 'includes allocations falling on the year boundaries' do
    allocation = FactoryGirl.create(:allocation, start_date: start_of_year, end_date: end_of_year)
    Allocation.this_year.should include(allocation)
  end

  it "does not include allocations starting before the year boundary" do
    allocation = FactoryGirl.create(:allocation, start_date: start_of_year - 1.day, end_date: end_date)
    Allocation.this_year.should_not include(allocation)
  end

  context "when destroyed" do

    let!(:allocation) { FactoryGirl.create(:allocation) }
    let!(:last_month) { RevenueItem.for_allocation!(allocation, day: (Date.today.beginning_of_month - 1)) }
    let!(:present) { RevenueItem.for_allocation!(allocation, day: Date.today) }
    let!(:future) { RevenueItem.for_allocation!(allocation, day: (Date.today + 1)) }

    it "destroyed future revenue items and nullifies past revenue items" do
      allocation.revenue_items.count.should eq(3)
      allocation.destroy
      expect(RevenueItem.exists?(last_month.id)).to be_truthy
      expect(RevenueItem.exists?(present.id)).to be_falsey
      expect(RevenueItem.exists?(future.id)).to be_falsey

      expect(last_month.reload.allocation_id).to be_nil
    end
  end

  # -       : denotes revenue item that is recalculated
  # x       : denotes revenue item that isn't recalculated
  # |       : denotes relevate date (see label)
  # [(x|-)] : denotes allocation

  # Beginning of month       Today    Arbitraty Future
  #         |                  |             |
  #   [xxxxx|------------------|-------------|---]
  #         |[-----------------|-------------|------]
  #         |                  |[------------|---------]
  #
  context "when updated" do

    let(:beginning_of_month) { Date.today.beginning_of_month }
    let(:some_day_last_month) { beginning_of_month.preceding_friday }
    let(:some_future_date) { Date.today.following_monday }

    let!(:allocation) do
      FactoryGirl.create(:allocation, binding:true, provisional: false, start_date: some_day_last_month, end_date: some_future_date)
    end

    let(:person) { allocation.person }

    before do
      # simulate having revenue items from a previous month
      person.revenue_items_for(some_day_last_month, Date.today + 1)
    end

    it "updates revenue items from this month and beyond and leave past alone" do
      allocation.provisional = true
      allocation.save!

      revenue_item_before_this_month = RevenueItem.for_allocation!(allocation, day: some_day_last_month)
      revenue_item_beginning_of_month = RevenueItem.for_allocation!(allocation, day: beginning_of_month)
      revenue_item_today = RevenueItem.for_allocation!(allocation, day: Date.today)
      revenue_item_future = RevenueItem.for_allocation!(allocation, day: some_future_date)

      expect(revenue_item_before_this_month.provisional).to be_falsey
      expect(revenue_item_beginning_of_month.provisional).to be_truthy
      expect(revenue_item_today.provisional).to be_truthy
      expect(revenue_item_future.provisional).to be_truthy
    end
  end

  describe '.week_days' do
    let(:monday_of_work_week) { Date.new(2014,6,23) }
    let(:friday_of_work_week) { Date.new(2014,6,27) }
    let(:tuesday_of_next_work_week) { Date.new(2014,7,1) }

    it 'has one day if the allocation is one day long' do
      allocation = FactoryGirl.create(:allocation, start_date: monday_of_work_week, end_date: monday_of_work_week)
      allocation.week_days.size.should eql(1)
    end

    it 'has five days if the allocation is one week long' do
      allocation = FactoryGirl.create(:allocation, start_date: monday_of_work_week, end_date: friday_of_work_week)
      allocation.week_days.size.should eql(5)
    end

    it 'omits weekend dates' do
      allocation = FactoryGirl.create(:allocation, start_date: monday_of_work_week, end_date: tuesday_of_next_work_week)
      allocation.week_days.size.should eql(7)
    end

  end

end
