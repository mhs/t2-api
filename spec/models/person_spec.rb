require 'spec_helper'

describe Person do
  describe '.currently_employed' do
    it 'includes someone without a start or end date' do
      employee = FactoryGirl.create(:person)
      Person.currently_employed.should include(employee)
    end
    it 'includes someone whose end date is in the future' do
      employee = FactoryGirl.create(:person, end_date: 1.week.from_now)
      Person.currently_employed.should include(employee)
    end
    it 'does not include someone whose end date is in the past' do
      non_employee = FactoryGirl.create(:person, end_date: 1.week.ago)
      Person.currently_employed.should_not include(non_employee)
    end
    it 'does not include someone whose start date is in the future' do
      non_employee = FactoryGirl.create(:person, start_date: 1.week.from_now)
      Person.currently_employed.should_not include(non_employee)
    end
  end
end
