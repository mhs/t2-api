require 'spec_helper'

describe Api::V1::DailyReportsController do

  before do
    sign_in :user, FactoryGirl.create(:user)
  end

  it "should serialize a daily report" do
    get :show, date: "20130228"

    parsed = JSON.parse(response.body)

    parsed["daily_report"]["snapshots"].should be_kind_of(Array)
    parsed["daily_report"]["offices"].should be_kind_of(Array)
    parsed["daily_report"]["report_date"].should eql("2013-02-28")
  end
end
