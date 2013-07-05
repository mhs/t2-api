# project = FactoryGirl.create(:project).offices.length # 1
# office = FactoryGirl.create(:office)
# project = FactoryGirl.create(:project, offices = [ office ])).offices.length # 1
FactoryGirl.define do
  factory :project do
    name     { Faker::Company.name }
    notes    { Faker::HipsterIpsum.sentence }
    billable { [true, false].sample }
    binding  { [true, false].sample }
    offices  { [ FactoryGirl.build(:office) ] }

    trait :billable do
      name  "Nexia"
      billable true
      binding true
    end
  end
end
