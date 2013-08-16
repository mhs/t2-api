require 'spec_helper'

describe Allocation do

  it 'should not be valid without a person' do
    FactoryGirl.build(:allocation, person: nil).should_not be_valid
  end

  it 'should not be valid without a project' do
    FactoryGirl.build(:allocation, project: nil).should_not be_valid
  end

  it 'should not be valid without a start date' do
    FactoryGirl.build(:allocation, start_date: nil).should_not be_valid
  end

  it 'should not be valid without a end_date' do
    FactoryGirl.build(:allocation, end_date: nil).should_not be_valid
  end

  it 'should not be valid with an end date before the start date' do
    FactoryGirl.build(:allocation, start_date: Date.today, end_date: 2.days.ago).should_not be_valid
  end

  describe "by_office Scope" do
    let(:office_a_person) { FactoryGirl.create(:person) }
    let(:office_b_person) { FactoryGirl.create(:person) }
    let(:project) { FactoryGirl.create(:project, offices: [office_a_person.office, office_b_person.office]) }

    before do
      @office_a_allocation = FactoryGirl.create(:allocation, project: project, person: office_a_person)
      @office_b_allocation = FactoryGirl.create(:allocation, project: project, person: office_b_person)
    end

    it 'should return an ActiveRecord::Relation Class' do
      Allocation.by_office(office_a_person).should be_kind_of(ActiveRecord::Relation)
      Allocation.by_office(nil).should be_kind_of(ActiveRecord::Relation)
    end

    it 'should be able to fetch Allocations for giveno Office' do
      Allocation.by_office(@office_a_allocation.office).count.should eql(1)
      Allocation.by_office(@office_a_allocation.office).should include(@office_a_allocation)
      Allocation.by_office(@office_b_allocation.office).count.should eql(1)
      Allocation.by_office(@office_b_allocation.office).should include(@office_b_allocation)
    end

    it 'should return all allocations if office is nil' do
      Allocation.by_office(nil).to_a.should eql(Allocation.all)
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

  describe '.with_start_date' do
    let!(:time_window) { Allocation::TIME_WINDOW }
    let!(:allocation_before) { FactoryGirl.create(:allocation, start_date: 3.weeks.ago, end_date: 1.week.ago) }
    let!(:allocation_start) { FactoryGirl.create(:allocation, start_date: 3.weeks.ago, end_date: 1.week.from_now) }
    let!(:allocation_end) { FactoryGirl.create(:allocation, start_date: 3.weeks.from_now, end_date: (time_window + 1).weeks.from_now) }
    let!(:allocation_after) { FactoryGirl.create(:allocation, start_date: (time_window + 1).weeks.from_now, end_date: (time_window + 5).weeks.from_now) }
    subject(:allocations) { Allocation.with_start_date( Date.today ) }

    it { should_not include allocation_before }
    it { should include allocation_start }
    it { should include allocation_end }
    it { should_not include allocation_after }
  end

  describe '.between_date_range' do
    let(:start_date) {1.month.ago}
    let(:end_date) {1.month.from_now}

    it 'includes allocations falling on the range boundaries' do
      allocation = FactoryGirl.create(:allocation, start_date: start_date, end_date: end_date)
      Allocation.between_date_range(start_date, end_date).should include(allocation)
    end

    it 'includes allocations inside the range boundaries' do
      allocation = FactoryGirl.create(:allocation, start_date: start_date + 1.day, end_date: end_date - 1.day)
      Allocation.between_date_range(start_date, end_date).should include(allocation)
    end

    it "does not include allocations starting before the range boundary" do
      allocation = FactoryGirl.create(:allocation, start_date: start_date - 1.day, end_date: end_date)
      Allocation.between_date_range(start_date, end_date).should_not include(allocation)
    end

    it "does not include allocations ending after the range boundary" do
      allocation = FactoryGirl.create(:allocation, start_date: start_date, end_date: end_date + 1.day)
      Allocation.between_date_range(start_date, end_date).should_not include(allocation)
    end
  end

  describe '.this_year' do
    let(:start_date) {1.month.ago}
    let(:end_date) {1.month.from_now}
    let(:start_of_year) { Date.today.beginning_of_year }
    let(:end_of_year) { Date.today.end_of_year }

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

    it "does not include allocations ending after the year boundary" do
      allocation = FactoryGirl.create(:allocation, start_date: start_date, end_date: end_of_year + 1.day)
      Allocation.this_year.should_not include(allocation)
    end
  end

  describe '.vacation' do
    let(:vacation_project) { FactoryGirl.create(:project, :vacation) }

    it 'includes allocations for vacation projects' do
      allocation = FactoryGirl.create(:allocation, project: vacation_project)
      Allocation.vacation.should include(allocation)
    end

    it 'does not include allocations for non-vacation projects' do
      allocation = FactoryGirl.create(:allocation)
      Allocation.vacation.should_not include(allocation)
    end
  end

  describe '.for_person' do
    let  (:bob) { FactoryGirl.create(:person) }
    let! (:bob_allocation) { FactoryGirl.create(:allocation, person: bob) }
    let! (:somoneone_elses_allocation) { FactoryGirl.create(:allocation) }

    it 'includes allocations for the specified person' do
      Allocation.for_person(bob).should include(bob_allocation)
      Allocation.for_person(bob.id).should include(bob_allocation)
    end

    it 'does not include allocations for other people' do
      Allocation.for_person(bob).should_not include(somoneone_elses_allocation)
    end
  end

end
