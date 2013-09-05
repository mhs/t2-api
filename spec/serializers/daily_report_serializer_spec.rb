require 'spec_helper'

describe DailyReportSerializer do

  let(:daily_report) { DailyReport.on_date(Date.today) }
  let(:serialized_daily_report) { DailyReportSerializer.new(daily_report) }

  before do
    Snapshot.on_date!(Date.today, FactoryGirl.create(:office))
  end

  it "should serialize with report_date" do
    serialized_daily_report.as_json[:daily_report][:report_date].should eql(Date.today)
  end

  it "should serialize with snapshots array" do
    serialized_daily_report.as_json[:daily_report][:snapshots].should be_kind_of(Array)
  end

  it "should serialize with office aside snapshots" do
    serialized_daily_report.as_json[:daily_report][:offices].should be_kind_of(Array)
  end
end
