require 'spec_helper'
require 'rake'

describe 'utilization_today rake task' do
  before :each do
    Rake.application.rake_require "tasks/utilization_today"
    Rake::Task.define_task(:environment)
    UtilizationTodayOutput.stub(:puts_names_for)
    UtilizationTodayOutput.stub(:utilization_puts)
  end

  it 'should output a bunch of names' do
    UtilizationTodayOutput.should_receive(:puts_names_for)
    Rake::Task['utilization_today'].reenable
    Rake.application.invoke_task 'utilization_today'
  end
end
