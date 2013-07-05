require 'spec_helper'

describe Project do
  describe '.unassignable' do
    it 'true if marked as a vacation project' do
      project = FactoryGirl.create(:project, vacation: true)
      Project.assignable.should include(project)
    end
    it 'false by default' do
      project = FactoryGirl.create(:project)
      Project.assignable.should_not include(project)
    end
  end
end
