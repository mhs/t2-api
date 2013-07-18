FactoryGirl.define do
  factory :person do
    office
    name   { Faker::Name.name }
    email  { Faker::Internet.email }
    notes  { Faker::HipsterIpsum.sentence }
  end

  trait :current do
    start_date { 1.year.ago }
    end_date   { 1.year.from_now }
  end

end
