require 'spec_helper'

describe DailyReport do

  describe '.daily_report_on' do
    let(:office) { FactoryGirl.create(:office) }
    let(:daily_report) { DailyReport.on_date(Date.today) }

    before do
      @snapshot = Snapshot.on_date!(Date.today, office_id: office.id)
    end

    it 'should be kind of DailyReport' do
      DailyReport.on_date(Date.today).should be_kind_of(DailyReport)
    end

    it 'should include date_report and snapshot' do
      daily_report.snapshots.should include(@snapshot)
      daily_report.report_date.should eql(Date.today)
    end

    it 'should not update snapshots' do
      daily_report.snapshots.first.updated_at.to_f.should eql(@snapshot.updated_at.to_f)
    end
  end
end
