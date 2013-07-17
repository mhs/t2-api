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
      snapshot.utilization.should_not be_empty
    end

    it 'includes utilization for the whole company' do
      snapshot.utilization.select{|u| u[:office_name] == 'Neo'}.should_not be_empty
    end
  end

  describe '.today' do
    before(:each) { Snapshot.today! }

    it 'provides a snapshot with todays date' do
      Snapshot.today.snap_date.should eql(Date.today)
    end

  end
end
