FactoryGirl.define do
  factory :person do
    office
    name    { Faker::Name.name }
    email   { Faker::Internet.email }
    notes   { Faker::HipsterIpsum.sentence }
    github  { "http://github.com/neo" }
    twitter { "https://twitter.com/neo_innovation" }
    title   { Faker::HipsterIpsum.sentence }
    bio     { Faker::HipsterIpsum.sentence }
    percent_billable { 100 }
  end

  trait :current do
    start_date { 1.year.ago }
    end_date   { 1.year.from_now }
  end

  trait :unsellable do
    percent_billable 0
  end

end
