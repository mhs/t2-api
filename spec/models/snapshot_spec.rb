require 'spec_helper'

describe Snapshot do
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

    before(:each) do
      employee = FactoryGirl.create(:person, :current)
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
      snapshot.office.should be_nil
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
    let(:date)            { 1.month.ago.to_date }
    let(:snapshot)        { Snapshot.new(snap_date: date) }
    let(:collection)      { [ FactoryGirl.create(:person) ] }
    let(:collection_ids)  { collection.map(&:id) }
    let(:scope) do
      scope = mock()
    end

    before do
      Person.should_receive(:employed_on_date).with(date).at_least(3).times.and_return(collection)
      Person.should_receive(:unassignable_on_date).with(date).once.and_return(collection)
      Person.should_receive(:billing_on_date).with(date).once.and_return(collection)
    end

    it 'should fetch staff_ids, overhead_ids, billable_ids, unassignable_ids' do
      snapshot.capture_data

      snapshot.staff_ids.should eql(collection_ids)
      snapshot.overhead_ids.should eql(collection_ids)
      snapshot.billable_ids.should eql(collection_ids)
      snapshot.unassignable_ids.should eql(collection_ids)
      snapshot.billing_ids.should eql(collection_ids)
    end
  end
end
