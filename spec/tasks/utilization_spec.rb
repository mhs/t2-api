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
end
