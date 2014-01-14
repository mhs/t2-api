require 'spec_helper'
describe WeightCalculator do
  describe '.unassignable_on_date by office' do
    let(:date) { Date.today }
    let(:project) { FactoryGirl.create(:project, :vacation) }
    let(:office_employee) { FactoryGirl.create(:person) }
    let(:other_office_employee) { FactoryGirl.create(:person) }

    before do
      FactoryGirl.create(:allocation, project: project, person: office_employee, start_date: 1.week.ago, end_date: Date.tomorrow)
      FactoryGirl.create(:allocation, project: project, person: other_office_employee, start_date: 1.week.ago, end_date: Date.tomorrow)
    end

    it 'should return unassignable people by office' do
      Person.unassignable_on_date(date, office_employee.office).should include(office_employee)
      Person.unassignable_on_date(date, office_employee.office).should_not include(other_office_employee)
    end
  end

  describe '.unassignable_on_date with today as date' do
    let(:date) { Date.today }
    let(:vacation) { FactoryGirl.create(:project, :vacation) }

    it 'includes someone allocated to vacation today' do
      employee = FactoryGirl.create(:person)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_on_date(date).should include(employee)
    end

    it 'includes them only once even if they are billed on two vacation projects' do
      employee = FactoryGirl.create(:person)
      conference = FactoryGirl.create(:project, :vacation)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      FactoryGirl.create(:allocation, person: employee, project: conference, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_on_date(date).should include(employee)
      Person.unassignable_on_date(date).size.should eql(1)
    end

    it 'does not include someone allocated to a billable project today' do
      employee = FactoryGirl.create(:person)
      project = FactoryGirl.create(:project, :billable)
      FactoryGirl.create(:allocation, person: employee, project: project, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_on_date(date).should_not include(employee)
    end

    it 'does not include someone who is unsellable' do
      employee = FactoryGirl.create(:person, :unsellable)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.unassignable_on_date(date).should_not include(employee)
    end

    it 'does not include someone who no longer works here' do
      former_employee = FactoryGirl.create(:person)
      FactoryGirl.create(:allocation, person: former_employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      former_employee.update_attributes!(end_date: Date.yesterday)
      Person.unassignable_on_date(date).should_not include(former_employee)
    end
  end

  describe '.billing_on_date with -today- as value' do
    let(:date) { Date.today }
    let(:billable_project) { FactoryGirl.create(:project, :billable) }
    let(:unbillable_project) { FactoryGirl.create(:project, :unbillable) }
    let(:employee) { FactoryGirl.create(:person) }

    it 'includes someone allocated to a billable project today' do
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      Person.billing_on_date(date).should include(employee)
    end

    it 'includes the person only once, even if they are allocated to two different projects' do
      another_billable_project = FactoryGirl.create(:project, billable: true)
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      FactoryGirl.create(:allocation, person: employee, project: another_billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      Person.billing_on_date(date).should include(employee)
      Person.billing_on_date(date).size.should eql(1)
    end

    it 'does not include someone allocated to a billable project in an unbillable way' do
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: false)
      Person.billing_on_date(date).should_not include(employee)
    end

    it 'does not include someone allocated to an unbillable project' do
      unbillable_project = FactoryGirl.create(:project, billable: false)
      FactoryGirl.create(:allocation, person: employee, project: unbillable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: false)
      Person.billing_on_date(date).should_not include(employee)
    end

    it 'does not include someone on vacation' do
      vacation = FactoryGirl.create(:project, :vacation)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.week.ago, end_date: Date.tomorrow)
      Person.billing_on_date(date).should_not include(employee)
    end

    it 'does not include someone on vacation if they are also allocated to a billable project' do
      vacation = FactoryGirl.create(:project, :vacation)
      FactoryGirl.create(:allocation, person: employee, project: vacation, start_date: 1.day.ago, end_date: Date.tomorrow)
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: 1.week.from_now, billable: true)
      Person.billing_on_date(date).should_not include(employee)
    end

    it 'does include someone who is billing even though they are unsellable' do
      overhead_employee = FactoryGirl.create(:person, :unsellable)
      FactoryGirl.create(:allocation, person: overhead_employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      Person.billing_on_date(date).should include(overhead_employee)
    end

    it 'does not include someone who is marked as unbillable even if the project is billable and they are not available' do
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: false, binding: true)
      Person.billing_on_date(date).should_not include(employee)
    end

    it 'does not include someone who is marked as unbillable/unavailable if the project itself is not billable' do
      FactoryGirl.create(:allocation, person: employee, project: unbillable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: false, binding: true)
      Person.billing_on_date(date).should_not include(employee)
    end

    it 'should be able to filter by office' do
      FactoryGirl.create(:allocation, person: employee, project: billable_project, start_date: 1.week.ago, end_date: Date.tomorrow, billable: true)
      Person.billing_on_date(date, employee.office).should include(employee)
      Person.billing_on_date(date, FactoryGirl.create(:office)).should_not include(employee)
    end
  end
end
