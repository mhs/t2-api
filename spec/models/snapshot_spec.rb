require 'spec_helper'

describe Snapshot do
  describe 'Validations' do
    it 'should not allow two snapshots for given date and office' do
      Snapshot.create!(snap_date: Date.today, office_id: 1)
      expect do
        Snapshot.create!(snap_date: Date.today, office_id: 1)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect do
        Snapshot.create!(snap_date: Date.tomorrow, office_id: 1)
      end.not_to raise_error
    end
  end

  describe '.one_per_day' do
    it 'is empty if there are no snapshots' do
      Snapshot.one_per_day.should be_empty
    end

    it 'returns the snapshot for today' do
      Snapshot.today!
      Snapshot.one_per_day.should_not be_empty
    end

    it 'returns only the most recent snapshot for the day' do
      Snapshot.today!
      Snapshot.today!
      Snapshot.one_per_day.size.should eql(1)
    end
  end

  describe '.on_date!' do
    let(:snapshot) {Snapshot.on_date!(Date.today)}
    let(:employee) {FactoryGirl.create(:person, :current)}

    before(:each) do
      FactoryGirl.create(:allocation, :active, :billable, person: employee)
    end

    it 'creates a snapshot' do
      expect{Snapshot.on_date!(Date.today)}.to change{Snapshot.count}.by(1)
    end

    it 'creates a snapshot for the given office' do
      snapshot = Snapshot.on_date!(Date.today, 1)
      snapshot.office_id.should eql(1)
      snapshot.should be_persisted
    end

    it 'should raise an error when invoked without arguments' do
      expect{Snapshot.on_date!}.to raise_error(ArgumentError)
    end

    it 'sets the snapshot date' do
      date = 3.days.ago
      Snapshot.on_date!(date).snap_date.should eql(date)
    end

    it 'captures currently employed staff' do
      snapshot.staff.should_not be_empty
    end

    it 'defaults the office to the entire company' do
      snapshot.office.class.should == Office::SummaryOffice
    end

    describe 'Updating Snapshots' do
      before do
        FactoryGirl.create(:allocation, :active, :billable)
      end

      it 'should not create a new snapshot when exists a snapshot for the given day' do
        snapshot

        lambda do
          Snapshot.on_date!(Date.today)
        end.should_not change(Snapshot, :count).by(1)
      end

      it 'should update existent snapshot' do
        snapshot.id.should eql(Snapshot.on_date!(Date.today).id)
      end

      it 'should update captured data' do
        Snapshot.on_date!(Date.today).billing_ids.count.should eql(2)
      end
    end
  end

  describe '.calculate_utilization' do
    let(:snapshot) { Snapshot.new }

    it 'should return 0 if there is no assignable people' do
      snapshot.billing_ids = [1,2,3]
      snapshot.assignable_ids = []
      snapshot.calculate_utilization.should eql(0.0)
    end
  end

  describe '.today!' do
    it "should call .on_date with today's date" do
      Snapshot.should_receive(:on_date!).with(Date.today)
      Snapshot.today!
    end
  end

  describe '.today' do
    before(:each) { Snapshot.today! }

    it 'provides a snapshot with todays date' do
      Snapshot.today.snap_date.should eql(Date.today)
    end
  end

  describe '.capture_data' do
    let(:office)           { FactoryGirl.create(:office) }
    let(:person_in_office) { FactoryGirl.create(:person, office: office) }
    let(:date)             { 1.month.ago.to_date }
    let(:snapshot)         { Snapshot.new(snap_date: date) }
    let(:collection)       { [ FactoryGirl.create(:person) ] }
    let(:collection_ids)   { collection.map(&:id) }
    let(:scope) do
      scope = mock()
    end

    it 'should fetch staff_ids, overhead_ids, billable_ids, unassignable_ids' do
      collection.stub(pluck: collection_ids)
      Person.should_receive(:employed_on_date).with(date).at_least(3).times.and_return(collection)
      Person.should_receive(:unassignable_on_date).with(date, nil).once.and_return(collection)
      Person.should_receive(:billing_on_date).with(date, nil).once.and_return(collection)

      snapshot.capture_data

      snapshot.staff_ids.should eql(collection_ids)
      snapshot.overhead_ids.should eql(collection_ids)
      snapshot.billable_ids.should eql(collection_ids)
      snapshot.unassignable_ids.should eql(collection_ids)
      snapshot.billing_ids.should eql(collection_ids)
    end

    it 'should not include people from other offices in billing_ids' do
      FactoryGirl.create(:allocation, :active, :billable, {
        person: person_in_office,
        start_date: date - 2.days,
        end_date: date + 2.days
      })
      FactoryGirl.create(:allocation, :active, :billable, {
        person: FactoryGirl.create(:person), # Person from a different office
        start_date: date - 2.days,
        end_date: date + 2.days
      })

      snapshot.office = office
      snapshot.capture_data
      snapshot.billing_ids.should include(person_in_office.id)
      snapshot.billing_ids.length.should eql(1)
    end

    it 'should not include people from other offices in unassignable_ids' do
      vacation_project = FactoryGirl.create(:project, vacation: true)

      FactoryGirl.create(:allocation, :active, {
        project: vacation_project,
        person: person_in_office,
        start_date: date - 2.days,
        end_date: date + 2.days
      })
      FactoryGirl.create(:allocation, :active, {
        project: vacation_project,
        person: FactoryGirl.create(:person), # Person from a different office
        start_date: date - 2.days,
        end_date: date + 2.days
      })

      snapshot.office = office
      snapshot.capture_data
      snapshot.unassignable_ids.should include(person_in_office.id)
      snapshot.unassignable_ids.length.should eql(1)
    end

    it 'should return the right utilization ratio' do
      # This person will be present but will not have
      # an allocation. It should be taken into account
      # in the utilization ration calculation.
      FactoryGirl.create(:person, office: office)

      FactoryGirl.create(:allocation, :active, :billable, {
        person: person_in_office,
        start_date: date - 2.days,
        end_date: date + 2.days
      })
      FactoryGirl.create(:allocation, :active, :billable, {
        person: FactoryGirl.create(:person),
        start_date: date - 2.days,
        end_date: date + 2.days
      })

      snapshot.office = office
      snapshot.capture_data

      # Since there are two people in the snapshot's office
      # and only one of them belongs to an allocation, the
      # utilization ratio should be 50%
      snapshot.utilization.should eql("50.0")
    end
  end
end
