require 'spec_helper'
require 'rake'

require './lib/tasks/utilization/output'
module UtilizationOutput
  def puts_names_for(list); end;
  def utilization_puts(x = ''); end;
end

describe 'Utilization Rake Tasks' do
  before do
    FactoryGirl.create(:person)
    FactoryGirl.create(:office)
    Rake::Task.define_task(:environment)
  end

  describe 'utilization:today rake task' do
    before do
      Rake.application.rake_require "tasks/utilization/today"
    end

    it 'should call Snapshot#today!' do
      snapshot = Snapshot.today!
      Snapshot.should_receive(:today!).and_return(snapshot)
      Rake::Task['utilization:today'].invoke
    end
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
        date.should_not be_saturday
        date.should_not be_sunday
      end
    end
  end
end
