require 'spec_helper'

describe Snapshot do
  describe '.today!' do
    let(:snapshot) {Snapshot.today!}

    it 'creates a snapshot' do
      expect{Snapshot.today!}.to change{Snapshot.count}.by(1)
    end

    it 'sets the snapshot date to today' do
      snapshot.snap_date.should eql(Date.today)
    end

    it 'populates the utilization data for today' do
      snapshot.utilization.should_not be_nil
    end
  end

  describe '.today' do
    before(:each) { Snapshot.today! }

    it 'provides a snapshot with todays date' do
      Snapshot.today.snap_date.should eql(Date.today)
    end

  end
end
