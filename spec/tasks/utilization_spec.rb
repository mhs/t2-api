require 'rails_helper'
require 'date_range_helper'
require 'rake'

describe 'Utilization Rake Tasks' do
  include DateRangeHelper
  before do
    FactoryGirl.create(:person)
    FactoryGirl.create(:office)
    Rake::Task.define_task(:environment)
  end

  describe 'utilization:three_weeks rake task' do
    let(:office) { FactoryGirl.create(:office) }

    before do
      Rake.application.rake_require "tasks/utilization/three_weeks"
    end

    it 'should call Snapshot#on_date! several times' do
      days_count = 0
      with_week_days { days_count += 1 }
      Snapshot.should_receive(:on_date!).with(any_args).exactly(days_count + days_count * Office.count).ordered
      Rake::Task['utilization:three_weeks'].invoke
    end

    it 'should not call Snapshot#on_date! on weekends' do
      with_week_days do |date|
        expect(date).not_to be_saturday
        expect(date).not_to be_sunday
      end
    end
  end
end
