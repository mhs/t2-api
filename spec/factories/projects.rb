# project = FactoryGirl.create(:project).offices.length # 1
# office = FactoryGirl.create(:office)
# project = FactoryGirl.create(:project, offices = [ office ])).offices.length # 1
FactoryGirl.define do
  factory :project do
    name     { Faker::Company.name }
    notes    { Faker::HipsterIpsum.sentence }
    billable { [true, false].sample }
    binding  { [true, false].sample }

    trait :billable do
      name  "Nexia"
      billable true
      binding true
    end

    trait :unbillable do
      name  "T2"
      billable false
      binding false
    end


    trait :vacation do
      vacation true
    end
  end
end
