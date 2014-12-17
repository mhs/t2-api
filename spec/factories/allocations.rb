FactoryGirl.define do
  factory :allocation do
    person
    project
    notes      { Faker::HipsterIpsum.sentence }
    start_date { Date.today + - 1.week }
    end_date   { Date.today + 1.week }
    billable   { [true, false].sample }
    percent_allocated { 100 }
    likelihood { '90% Likely' }


    trait :this_week do
      start_date { Date.today.at_beginning_of_week }
      end_date { Date.today.at_beginning_of_week + 6.days }
    end

    trait :active do
      start_date { 1.week.ago }
      end_date { 1.week.from_now}
    end

    trait :billable do
      billable true
      binding true
    end

    trait :vacation do
      billable false
      binding true
    end

    trait :provisional do
      provisional true
    end
  end
end
