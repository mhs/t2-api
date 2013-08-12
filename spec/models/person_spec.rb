require 'spec_helper'

describe Person do
  it 'acts as paranoid' do
    Person.count.should eql(0)
    Person.only_deleted.should be_empty

    person = FactoryGirl.create(:person)

    Person.count.should_not eql(0)

    person.destroy

    Person.count.should eql(0)
    Person.only_deleted.should_not be_empty
  end

  describe '.currently_employed' do
    it 'includes someone without a start or end date' do
      employee = FactoryGirl.create(:person)
      Person.currently_employed.should include(employee)
    end
    it 'includes someone whose end date is in the future' do
      employee = FactoryGirl.create(:person, end_date: 1.week.from_now)
      Person.currently_employed.should include(employee)
    end
    it 'does not include someone whose end date is in the past' do
      non_employee = FactoryGirl.create(:person, end_date: 1.week.ago)
      Person.currently_employed.should_not include(non_employee)
    end
    it 'does not include someone whose start date is in the future' do
      non_employee = FactoryGirl.create(:person, start_date: 1.week.from_now)
      Person.currently_employed.should_not include(non_employee)
    end
    it 'does not include a person deleted in a paranoid way' do
      employee = FactoryGirl.create(:person)
      employee.destroy
      Person.currently_employed.should be_empty
    end
  end

  describe '.overhead' do
    it 'includes people marked as unsellable' do
      employee = FactoryGirl.create(:person, unsellable: true)
      Person.overhead.should include(employee)
    end

    it 'does not include people marked as sellable' do
      employee = FactoryGirl.create(:person, unsellable: false)
      Person.overhead.should_not include(employee)
    end

    it 'does not include deleted employees' do
      employee = FactoryGirl.create(:person, unsellable: true)
      employee.destroy
      Person.overhead.should_not include(employee)
    end
  end

  describe '.billable' do
    it 'does not include people marked as unsellable' do
      employee = FactoryGirl.create(:person, unsellable: true)
      Person.billable.should_not include(employee)
    end

    it 'includes people marked as sellable' do
      employee = FactoryGirl.create(:person, unsellable: false)
      Person.billable.should include(employee)
    end

    it 'does not include deleted employees' do
      employee = FactoryGirl.create(:person, unsellable: false)
      employee.destroy
      Person.billable.should_not include(employee)
    end
  end

  describe '.unassignable_today' do
    let(:vacation) { FactoryGirl.create(:project, :vacation) }

    it 'includes someone allocated to vacation today' do
      employee = FactoryGirl.create(:person, unsellable: false)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_today.should include(employee)
    end

    it 'includes them only once even if they are billed on two vacation projects' do
      employee = FactoryGirl.create(:person, unsellable: false)
      conference = FactoryGirl.create(:project, :vacation)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      FactoryGirl.create(:allocation, person: employee, project: conference, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_today.should include(employee)
      Person.unassignable_today.size.should eql(1)
    end


    it 'does not include someone allocated to a billable project today' do
      employee = FactoryGirl.create(:person, unsellable: false)
      project = FactoryGirl.create(:project, :billable)
      FactoryGirl.create(:allocation, person: employee, project: project, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_today.should_not include(employee)
    end

    it 'does not include someone who is unsellable' do
      employee = FactoryGirl.create(:person, unsellable: true)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_today.should_not include(employee)
    end

    it 'does not include someone who no longer works here' do
      former_employee = FactoryGirl.create(:person)
      FactoryGirl.create(:allocation, person: former_employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      former_employee.update_attributes!(end_date: Date.yesterday)
      Person.unassignable_today.should_not include(former_employee)
    end
  end

  describe '.billing_today' do
    let(:billable_project) { FactoryGirl.create(:project, :billable) }
    let(:employee) { FactoryGirl.create(:person) }

    it 'includes someone allocated to a billable project today' do
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      Person.billing_today.should include(employee)
    end

    it 'includes the person only once, even if they are allocated to two different projects' do
      another_billable_project = FactoryGirl.create(:project, billable: true)
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      FactoryGirl.create(:allocation, person: employee, project: another_billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      Person.billing_today.should include(employee)
      Person.billing_today.size.should eql(1)
    end

    it 'does not include someone allocated to a billable project in an unbillable way' do
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: false)
      Person.billing_today.should_not include(employee)
    end

    it 'does not include someone allocated to an unbillable project' do
      unbillable_project = FactoryGirl.create(:project, billable: false)
      FactoryGirl.create(:allocation, person: employee, project: unbillable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: false)
      Person.billing_today.should_not include(employee)
    end

    it 'does not include someone on vacation' do
      vacation = FactoryGirl.create(:project, :vacation)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.billing_today.should_not include(employee)
    end

    it 'does not include someone on vacation if they are also allocated to a billable project' do
      vacation = FactoryGirl.create(:project, :vacation)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.day.ago, end_date: Date.tomorrow)
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: 1.week.from_now, billable: true)
      Person.billing_today.should_not include(employee)
    end

    it 'does include someone who is billing even though they normall do not' do
      overhead_employee = FactoryGirl.create(:person, unsellable: true)
      FactoryGirl.create(:allocation, person: overhead_employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      Person.billing_today.should include(overhead_employee)
    end
  end

  describe ".pto_requests" do
    let(:start_of_year) { Date.today.beginning_of_year }
    let(:end_of_year) { Date.today.end_of_year }
    let(:employee) { FactoryGirl.create(:person) }
    let(:billable_project) { FactoryGirl.create(:project, :billable) }
    let(:vacation_project) { FactoryGirl.create(:project, :vacation) }

    let!(:vacation_alloc) { FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: 1.day.ago, end_date: Date.tomorrow) }
    let!(:billable_alloc) { FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: 1.week.from_now) }
    let!(:vacation_alloc_last_year) { FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: 15.months.ago, end_date: 13.months.ago) }

    it 'includes allocations from this year that are vacatation' do
      employee.pto_requests.should include(vacation_alloc)
    end

    it 'should not include allocations from this year that are not vacation' do
      employee.pto_requests.should_not include(billable_alloc)
    end

    it 'should not include allocations from last year that are vacatation' do
      employee.pto_requests.should_not include(vacation_alloc_last_year)
    end
  end
end
