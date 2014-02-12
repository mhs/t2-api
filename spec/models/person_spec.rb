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

  context 'creating new project allowances' do
    let(:vacation) { FactoryGirl.create(:project, :vacation) }
    let(:office)   { FactoryGirl.create(:office) }

    before do
      office.project_offices.create(allowance: 160) do |po|
        po.project = vacation
      end
    end

    it 'creates an allowance for all projects person currently lacks an allowance for' do
       expect {
         FactoryGirl.create(:person, office: office)
       }.to change(ProjectAllowance, :count).by(1)
    end

    it 'doesnt overwrite existing allowances' do
      person = FactoryGirl.create(:person, office: office)
      person.project_allowances.first.update_attribute(:hours, 40)

      expect {
        person.update_attributes({name: Time.now})
      }.to_not change(ProjectAllowance, :count)

      expect(person.project_allowances.first.hours).to eq(40)
    end
  end

  it "does not allow duplicate emails" do
    person = FactoryGirl.create(:person, email: "joe@example.com")
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
    let(:email) { email = 'neon@example.com' }

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

  describe "#similar_people" do
    let(:person) { FactoryGirl.create(:person, skill_list: ["ruby", "javascript", "android"]) }

    before do
      @joe = FactoryGirl.create(:person, skill_list: ["android"])
      @ben = FactoryGirl.create(:person, skill_list: ["ios", "ruby", "javascript"])
      @bob = FactoryGirl.create(:person, skill_list: ["ios", "php"])
    end

    it "should return a list of people with similar tags" do
      pending "skill_list not implemented"

      person.similar_people.should include(@joe, @ben)
      person.similar_people.should_not include(@bob)
    end

    it "should order by most relevant people" do
      pending "skill_list not implemented"

      person.similar_people.should eql([@ben, @joe])
    end

    it "should return a maximun of 1 results" do
      pending "skill_list not implemented"

      person.similar_people(1).should eql([@ben])
    end
  end
end
