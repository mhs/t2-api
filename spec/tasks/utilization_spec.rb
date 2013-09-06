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

    it 'should call Snapshot#on_date! with and without office_id several times' do
      Snapshot.should_receive(:on_date!).with(kind_of(Date)).any_number_of_times.ordered
      Snapshot.should_receive(:on_date!).with(kind_of(Date), kind_of(Numeric)).any_number_of_times.ordered
      Rake::Task['utilization:three_weeks'].invoke
    end

    it 'should not call Snapshot#on_date! on weekends' do
      ((Date.today)..(21.days.from_now.to_date)).select do |date|
        if date.saturday? || date.sunday?
          Snapshot.should_not_receive(:on_date!).with(date).any_number_of_times.ordered
          Snapshot.should_not_receive(:on_date!).with(date, kind_of(Numeric)).any_number_of_times.ordered
        end
      end
    end
  end
end
