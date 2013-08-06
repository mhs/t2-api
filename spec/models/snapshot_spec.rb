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

  describe '.today!' do
    let(:snapshot) {Snapshot.today!}

    before(:each) do
      employee = FactoryGirl.create(:person, :current)
      FactoryGirl.create(:allocation, :active, :billable, person: employee)
    end

    it 'creates a snapshot' do
      expect{Snapshot.today!}.to change{Snapshot.count}.by(1)
    end

    it 'sets the snapshot date to today' do
      snapshot.snap_date.should eql(Date.today)
    end

    it 'captures currently employed staff' do
      snapshot.staff.should_not be_empty
    end

    it 'defaults the office to the entire company' do
      snapshot.office.should be_nil
    end
  end

  describe '.today' do
    before(:each) { Snapshot.today! }

    it 'provides a snapshot with todays date' do
      Snapshot.today.snap_date.should eql(Date.today)
    end

  end
end
