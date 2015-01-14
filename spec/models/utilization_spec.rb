require 'spec_helper'

describe Utilization do

  describe '#vacation_allocation_percentage' do
    it 'aint nobody get more then 100% allocation to vacation on the same day' do
      person = FactoryGirl.create(:person)
      project = FactoryGirl.create(:project, :vacation)
      2.times do
        FactoryGirl.create(:allocation, :vacation, person: person, project: project)
      end

      Utilization.new(person: person, includes_speculative: false).vacation_allocation_percentage.should eq(100.0)
    end
  end

end
