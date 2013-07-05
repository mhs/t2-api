FactoryGirl.define do
  factory :allocation do
    person
    project
    notes      { Faker::HipsterIpsum.sentence }
    start_date { Date.today + (-5..3).to_a.sample.weeks }
    end_date   { Date.today + (4..9).to_a.sample.weeks }
    billable   { [true, false].sample }

    trait :this_week do
      start_date { Date.today.at_beginning_of_week }
      end_date { Date.today.at_beginning_of_week + 6.days }
    end
  end
end
