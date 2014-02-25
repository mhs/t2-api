require 'spec_helper'

describe ProjectOffice do
  let(:vacation)  { FactoryGirl.create(:project, :vacation) }
  let(:office)    { FactoryGirl.create(:office) }
  let(:sally)     { FactoryGirl.create(:person, office: office) }
  let(:bob)       { FactoryGirl.create(:person, office: office) }

end
