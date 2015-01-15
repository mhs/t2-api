require 'rails_helper'

describe DailyReport do

  describe '.daily_report_on' do
    let(:office) { FactoryGirl.create(:office) }
    let(:daily_report) { DailyReport.on_date(Date.today) }

    before do
      @snapshot = Snapshot.on_date!(Date.today, office_id: office.id)
    end

    it 'should be kind of DailyReport' do
      expect(DailyReport.on_date(Date.today)).to be_kind_of(DailyReport)
    end

    it 'should include date_report and snapshot' do
      expect(daily_report.snapshots).to include(@snapshot)
      expect(daily_report.report_date).to eql(Date.today)
    end

    it 'should not update snapshots' do
      expect(daily_report.snapshots.first.updated_at.to_f).to eql(@snapshot.updated_at.to_f)
    end
  end
end
