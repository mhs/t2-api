require 'rails_helper'

describe AllocationBundle do
  let(:project) { FactoryGirl.create(:project, start_date: Date.today - 1.week, end_date: Date.today + 2.weeks)}
  let(:person)  { FactoryGirl.create(:person, :current)}
  let!(:allocation) { FactoryGirl.create(:allocation, :active, project: project, person: person)}

  describe '#projects' do
    it 'includes projects within a date range' do
      expect(AllocationBundle.new(current_start, current_end).projects).to include(project)
    end

    it 'does not include projects outside a date range' do
      expect(AllocationBundle.new(in_the_past_start, in_the_past_end).projects).not_to include(project)
    end
  end

  describe '#allocations' do
    it 'includes allocations within a date range' do
      expect(AllocationBundle.new(current_start, current_end).allocations).to include(allocation)
    end

    it 'does not include allocations outside a date range' do
      expect(AllocationBundle.new(in_the_past_start, in_the_past_end).allocations).not_to include(allocation)
    end

    context 'ended employees' do
      let(:person) {  FactoryGirl.create(:person, start_date: 2.years.ago, end_date: 1.year.ago) }

      it 'does not include allocations for employee with end date before range' do
        expect(AllocationBundle.new(current_start, current_end).allocations).not_to include(allocation)
      end
    end
  end

  describe '#people' do
    it 'includes people who are employed within a date range' do
      expect(AllocationBundle.new(current_start, current_end).people).to include(allocation.person)
    end

    it 'does not include people who were not employed during a date range' do
      expect(AllocationBundle.new(years_ago_start, years_ago_end).people).not_to include(allocation.person)
    end
  end

  describe '#conflicts' do
  end

  describe '#availabilities' do
  end
end

def current_start
  Date.today
end

def current_end
  current_start + 1.week
end

def in_the_past_start
  Date.today - 1.month
end

def in_the_past_end
  in_the_past_start + 1.week
end

def years_ago_start
  Date.today - 2.years
end

def years_ago_end
  years_ago_start + 1.week
end
