require 'rails_helper'

describe Person do

  it 'acts as paranoid' do
    Person.count.should eql(0)
    Person.deleted.should be_empty

    person = FactoryGirl.create(:person)

    Person.count.should_not eql(0)

    person.destroy

    Person.count.should eql(0)
    Person.deleted.should be_empty
  end

  it "does not allow duplicate emails" do
    FactoryGirl.create(:person, email: "joe@example.com")
    person2 = FactoryGirl.build(:person, email: "joe@example.com")
    person2.should_not be_valid
  end

  describe 'by_office Scope' do
    let!(:office_a_person) { FactoryGirl.create(:person) }
    let!(:office_b_person) { FactoryGirl.create(:person) }

    it 'should return an ActiveRecord::Relation Class' do
      Person.by_office(office_a_person).should be_kind_of(ActiveRecord::Relation)
      Person.by_office(nil).should be_kind_of(ActiveRecord::Relation)
    end

    it 'should return people that belongs to that office' do
      Person.by_office(office_a_person.office).should include(office_a_person)
      Person.by_office(office_b_person.office).should include(office_b_person)
    end

    it 'should return all people when office is nil' do
      Person.by_office(nil).to_a.should eql(Person.all.to_a)
    end
  end

  describe 'associating with User' do
    let(:email) { 'neon@example.com' }

    it 'should associate a new person with an already created user' do
      user = FactoryGirl.create(:user, email: email)
      person = FactoryGirl.create(:person, email: email)
      expect(person.user).to eq(user)
    end

    it 'should create a new user if one doesnt exist' do
      person = nil

      expect {
        person = FactoryGirl.create(:person, email: email)
        expect(person.user.email).to eq(email)
      }.to change(User, :count).by(1)

      person.reload.user_id.should_not be_nil
    end
  end

  describe '.employed_on_date with today as date' do
    let(:date) { Date.today }

    it 'includes someone without a start or end date' do
      employee = FactoryGirl.create(:person)
      Person.employed_on_date(date).should include(employee)
    end

    it 'includes someone whose end date is in the future' do
      employee = FactoryGirl.create(:person, end_date: 1.week.from_now)
      Person.employed_on_date(date).should include(employee)
    end

    it "does include someone whose start date is on the given date" do
      employee = FactoryGirl.create(:person, start_date: date)
      Person.employed_on_date(date).should include(employee)
    end

    it "does include someone whose end date is on the given date" do
      employee = FactoryGirl.create(:person, end_date: date)
      Person.employed_on_date(date).should include(employee)
    end

    it 'does not include someone whose end date is in the past' do
      non_employee = FactoryGirl.create(:person, end_date: 1.week.ago)
      Person.employed_on_date(date).should_not include(non_employee)
    end

    it 'does not include someone whose start date is in the future' do
      non_employee = FactoryGirl.create(:person, start_date: 1.week.from_now)
      Person.employed_on_date(date).should_not include(non_employee)
    end

    it 'does not include a person deleted in a paranoid way' do
      employee = FactoryGirl.create(:person)
      employee.destroy
      Person.employed_on_date(date).should be_empty
    end
  end

  describe '.overhead' do
    it 'includes people who are < 100% billable' do
      employee = FactoryGirl.create(:person, :unsellable)
      Person.overhead.should include(employee)
    end

    it 'does not include people marked as sellable' do
      employee = FactoryGirl.create(:person)
      Person.overhead.should_not include(employee)
    end

    it 'does not include deleted employees' do
      employee = FactoryGirl.create(:person, :unsellable)
      employee.destroy
      Person.overhead.should_not include(employee)
    end
  end

  describe '.billable' do
    it 'does not include people marked as unsellable' do
      employee = FactoryGirl.create(:person, :unsellable)
      Person.billable.should_not include(employee)
    end

    it 'includes people marked as sellable' do
      employee = FactoryGirl.create(:person)
      Person.billable.should include(employee)
    end

    it 'does not include deleted employees' do
      employee = FactoryGirl.create(:person)
      employee.destroy
      Person.billable.should_not include(employee)
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

  describe ".pto_this_year" do
    before { Timecop.freeze(Date.new(2014,7,1)) }
    after { Timecop.return }

    let!(:office) { FactoryGirl.create(:office) }
    let!(:employee) { FactoryGirl.create(:person, office: office) }
    let!(:vacation_project) { FactoryGirl.create(:project, :vacation, name: 'vacation') }
    let!(:holiday_project) { FactoryGirl.create(:project, :holiday, name: 'holiday') }
    let(:vacation_time) { employee.pto_this_year['vacation'] }

    it 'includes company holidays' do
      Holiday.declare('Independence Day',[office],'2014-7-4')
      employee.pto_this_year['holiday'].should_not be_empty
    end

    it 'does not include holidays from last year' do
      Holiday.declare('Independence Day',[office],'2013-7-4')
      employee.pto_this_year['holiday'].should be_empty
    end

    it 'includes vacation days' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-7-1', end_date: '2014-7-1')
      vacation_time.should_not be_empty
      vacation_time.size.should eq(1)
    end

    it 'provides the actual days off' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-7-1', end_date: '2014-7-1')
      vacation_time[0].year.should eql(2014)
      vacation_time[0].month.should eql(7)
      vacation_time[0].day.should eql(1)
    end


    it 'does not include vacation days from last year' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2013-7-1', end_date: '2013-7-1')
      vacation_time.should be_empty
    end

    it 'includes every day of vacation' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-7-1', end_date: '2014-7-2')
      vacation_time.size.should eq(2)
    end

    it 'knows that holidays trump vacation days' do
      Holiday.declare('Independence Day',[office],'2014-7-4')
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-7-1', end_date: '2014-7-5')
      vacation_time.size.should eq(3)
    end

    it 'only includes parts of a vacation at the start of the year that are in this calendar year' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2013-12-29', end_date: '2014-1-2')
      vacation_time.size.should eq(2)
    end

    it 'only includes parts of a vacation at the end of the year that are in this calendar year' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-12-29', end_date: '2015-1-2')
      vacation_time.size.should eq(3)
    end

    it 'does not include weekend days' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-7-10', end_date: '2014-7-14')
      vacation_time.size.should eq(3)
    end

    it 'dedupes overlapping vacation allocations' do
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-7-10', end_date: '2014-7-14')
      FactoryGirl.create(:allocation, person: employee, project: vacation_project, start_date: '2014-7-10', end_date: '2014-7-14')
      vacation_time.size.should eq(3)
    end

  end

end
