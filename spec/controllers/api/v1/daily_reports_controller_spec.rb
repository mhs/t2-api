require 'rails_helper'

describe Api::V1::DailyReportsController do

  before do
    sign_in :user, FactoryGirl.create(:user)
  end

  it "should serialize a daily report" do
    get :show, date: "20130228"

    parsed = JSON.parse(response.body)

    expect(parsed["daily_report"]["snapshots"]).to be_kind_of(Array)
    expect(parsed["daily_report"]["offices"]).to be_kind_of(Array)
    expect(parsed["daily_report"]["report_date"]).to eql("2013-02-28")
  end
end
