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
end
