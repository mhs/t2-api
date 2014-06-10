# project = FactoryGirl.create(:project).offices.length # 1
# office = FactoryGirl.create(:office)
# project = FactoryGirl.create(:project, offices = [ office ])).offices.length # 1
FactoryGirl.define do
  factory :project, class: StandardProject do
    type     "StandardProject"
    name     { Faker::Company.name }
    notes    { Faker::HipsterIpsum.sentence }
    billable { [true, false].sample }
    binding  { [true, false].sample }
    office_ids { [FactoryGirl.create(:office).id] }

    rates do
      {
        'Developer' => 1000.0,
        'Designer' => 1100.0,
        'Principal' => 1200.0,
        'Product Manager' => 1300.0
      }
    end

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

    trait :holiday do
      holiday true
    end

    trait :provisional do
      provisional true
    end
  end
end
