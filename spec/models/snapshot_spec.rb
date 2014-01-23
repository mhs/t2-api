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
      date = 3.days.ago.to_date
      Snapshot.on_date!(date).snap_date.should eql(date)
    end

    it 'captures currently employed staff' do
      snapshot.staff_weights.should_not be_empty
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
        Snapshot.on_date!(Date.today).billing_weights.size.should eql(2)
      end
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
    let(:date)             { 1.month.ago.to_date }
    let(:snapshot)         { Snapshot.new(snap_date: date) }

    def pw(person)
      [person.name, person.percent_billable]
    end

    def wset(*pairs)
      res = {}
      pairs.flatten.each_slice(2) do |(k, v)|
        res[k] = v
      end
      WeightedSet.new res
    end

    def allocation_for(person, options={})
      FactoryGirl.create(:allocation, { start_date: date, end_date: date, person: person, binding: true, billable: true }.merge(options))
    end

    context "with a developer and a staff member" do
      let!(:dev) { FactoryGirl.create(:person, office: office) }
      let!(:pm) { FactoryGirl.create(:person, office: office, percent_billable: 50) }
      let!(:staff) { FactoryGirl.create(:person, :unsellable, office: office) }
      let(:staff_weights) { wset pw(dev), pw(pm), pw(staff) }
      let(:unassignable_weights) { wset pw(staff) }
      let(:assignable_weights) { wset pw(dev), pw(pm) }

      it 'should fetch staff_weights, assignable_weights' do
        snapshot.capture_data
        expect(snapshot.staff_weights).to eq(staff_weights)
        expect(snapshot.assignable_weights).to eq(assignable_weights)
      end

      context "with an allocation for the developer" do
        let!(:alloc) { allocation_for(dev) }

        it "the pm should not be billing and staff isn't included." do
          snapshot.capture_data
          expect(snapshot.billing_weights).to eq(wset(dev.name, 100))
          expect(snapshot.non_billing_weights).to eq(wset(pm.name, 50))
        end
      end

      context "a dev on vacation" do
        let!(:vacation_allocation) do
          vacation_project = FactoryGirl.create(:project, vacation: true)
          allocation_for dev, project: vacation_project, billable: false
        end

        it "shows the dev as unassignable" do
          snapshot.capture_data
          expect(snapshot.unassignable_weights).to eq(wset(dev.name, 100))
        end
      end

      context "with people from another office" do
        let(:other_office) { FactoryGirl.create :office }
        let(:other_guy) { FactoryGirl.create :person, office: other_office }
        it "doesn't include them in snapshots for the first office" do
          allocation_for(dev)
          allocation_for(other_guy)
          snapshot.office = office
          snapshot.capture_data

          expect(snapshot.staff_weights).to eq(staff_weights)
          expect(snapshot.billing_weights).not_to include(other_guy.name)
        end
      end

      it 'should return the right utilization ratio' do
        # This person will be present but will not have
        # an allocation. It should be taken into account
        # in the utilization ration calculation.
        FactoryGirl.create(:person, office: office)

        allocation_for(dev)
        FactoryGirl.create(:allocation, :active, :billable, {
          person: FactoryGirl.create(:person),
          start_date: date - 2.days,
          end_date: date + 2.days
        })

        snapshot.office = office
        snapshot.capture_data

        # Since there are three people in the snapshot's office
        # but one of them is only 50% billable and only one has
        # an allocation, the utilization should be:
        #
        # billing          100 + 0 + 0
        # -------     =  ---------------- = 40%
        # assignable      100 + 100 + 50
        #
        snapshot.utilization.should eql("40.0")
      end
    end
  end
end
